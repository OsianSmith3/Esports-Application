//
//  barStats.swift
//  Esports Application
//
//  Created by Osian Smith on 21/04/2024.
//

import SwiftUI

struct BarUser: Codable { // Change variable name to BarUser
    let id: Int
    let username: String
}

struct UserStatsView: View {
    @State private var searchText: String = ""
    @StateObject private var viewModel = UserStatsViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Beyond All Reason Stats")
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                
                HStack {
                    TextField("Enter username", text: $searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    Button(action: {
                        Task {
                            viewModel.errorMessage = nil // Reset error message
                            await viewModel.loadStats(for: searchText)
                        }
                    }) {
                        Text("Load Stats")
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                if viewModel.dataReceived {
                    // Display user stats
                    if let barUser = viewModel.barUser {
                        VStack {
                            Text("User ID: \(barUser.id)")
                                .multilineTextAlignment(.center)
                            Text("Overall Stats for: \(barUser.username)")
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.gray)
                        .border(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 1), width: 1)
                        .cornerRadius(5)
                    }
                    
                    if let totalGames = viewModel.totalGames {
                        let winsCount = viewModel.winsCount ?? 0
                        let winPercentage = totalGames > 0 ? Double(winsCount) / Double(totalGames) * 100 : 0
                        VStack{
                            Text("Total Games: \(totalGames)")
                                .multilineTextAlignment(.center)
                            Text("Number of Wins: \(winsCount)")
                                .multilineTextAlignment(.center)
                            Text("Win Percentage: \(String(format: "%.2f", winPercentage))%")
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.gray)
                        .border(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 1), width: 1)
                        .cornerRadius(5)
                    }
                        Spacer()
                    
                    //Here for when this is added.
                    //if let armadaTotalGames = viewModel.armadaTotalGames {
                        //let armadaTotalWins = viewModel.armadaTotalWins ?? 0
                        //let armadaWinPercentage = armadaTotalGames > 0 ? Double(armadaTotalWins)Double(armadaTotalGames) * 100 : 0
                            //Text("Armada Total Games: \(armadaTotalGames)")
                            //Text("Armada Total Wins: \(armadaTotalWins)")
                            //Text("Win Percentage as Armada: \(String(format: "%.2f", armadaWinPercentage))")
                        //}
                                 
                    
                    // Display line chart
                    if let lineChartData = viewModel.lineChartData {
                        LineChart(data: lineChartData)
                            .frame(height: 200)
                            .padding()
                    } else {
                        Text("Line chart data is not available")
                            .padding()
                    }
                }
                    
                if viewModel.isLoading {
                    ProgressView("Loading Stats...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .padding()
                }
                
                Spacer()
            }
        }
    }
}
struct LineChart: View {
    let data: LineChartData
    var body: some View {
           ScrollView(.horizontal) {
               HStack(spacing: 6) {
                   VStack {
                           Group{
                               Text("Wins") +
                               Text(" & ").foregroundColor(.black) +
                               Text("Losses").foregroundColor(.red)
                           }
                                   .rotationEffect(Angle(degrees: -90))
                                   .padding(.bottom, 10)
                                   .font(.headline)
                                   .foregroundColor(.green)
                       }
                   
                   ForEach(0..<data.xData.count, id: \.self) { index in
                       VStack {
                           Text(data.xData[index])
                           Rectangle()
                               .fill(Color.green)
                               .frame(width: 30, height: CGFloat(data.yData[index].0) * 10) // Wins
                           Text("\(data.yData[index].0)")
                               .foregroundColor(.green)
                       }
                       .padding(.trailing, 4)
                       
                       VStack {
                           Text("\(data.yData[index].1)")
                               .foregroundColor(.red)
                           Rectangle()
                               .fill(Color.red)
                               .frame(width: 30, height: CGFloat(data.yData[index].1) * 10) // Losses
                       }
                       .padding(.trailing, 4)
                   }
               }
           }
       }
   }

   struct LineChartData {
       let xData: [String] // Dates
       let yData: [(Int, Int)] // Wins and losses
   }

   @MainActor
   class UserStatsViewModel: ObservableObject {
       @Published var isLoading: Bool = false
       @Published var dataReceived: Bool = false
       @Published var totalGames: Int?
       @Published var winsCount: Int?
       @Published var barUser: BarUser?
       @Published var errorMessage: String?
       @Published var lineChartData: LineChartData?
       //@Published var armadaTotalGames: Int?
       //@Published var armadaTotalWins: Int?
       
       
       let decoder: JSONDecoder = {
           let decoder = JSONDecoder()
           decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full) // Set the date decoding strategy
           return decoder
       }()
       
       @MainActor
       func loadStats(for username: String) async {
           isLoading = true
           dataReceived = false
           
           guard let url = URL(string: "https://api.bar-rts.com/cached-users") else {
               // Handle invalid URL
               return
           }
           
           do {
               let (data, _) = try await URLSession.shared.data(from: url)
               
               let usersList = try decoder.decode([BarUser].self, from: data)
               if let barUser = usersList.first(where: { $0.username == username }) {
                   self.barUser = barUser // Set barUser property
                   let userId = barUser.id
                   await fetchMatches(for: userId, username: username)
                   dataReceived = true // Set dataReceived to true after fetching user data
               } else {
                   // User not found, set error message
                   errorMessage = "Player not found, please try again"
                   isLoading = false
                   
               }
           } catch {
               print("Error: \(error)")
               // Handle error
           }
       }
       
       
       private func fetchMatches(for userId: Int, username: String) async {
           var allMatches: [MatchData] = []
           var currentPage = 1
           
           repeat {
               guard var urlComponents = URLComponents(string: "https://api.bar-rts.com/replays") else {
                   // Handle invalid URL
                   return
               }
               
               let queryItems = [
                   URLQueryItem(name: "page", value: "\(currentPage)"),
                   URLQueryItem(name: "hasBots", value: "false"),
                   URLQueryItem(name: "endedNormally", value: "true"),
                   URLQueryItem(name: "preset", value: "team"),
                   URLQueryItem(name: "players", value: username),
                   URLQueryItem(name: "date", value: "2020-01-01"),
                   URLQueryItem(name: "date", value: "3024-06-30")
               ]
               
               urlComponents.queryItems = queryItems
               
               guard let url = urlComponents.url else {
                   // Handle invalid URL
                   return
               }
               
               do {
                   let (data, _) = try await URLSession.shared.data(from: url)
                   
                   let response = try decoder.decode(MatchDataResponse.self, from: data)
                   let matches = response.data
                   
                   if matches.isEmpty {
                       break
                   }
                   
                   allMatches.append(contentsOf: matches)
                   
                   currentPage += 1
               } catch {
                   print("Error: \(error)")
                   // Handle error
                   break
               }
           } while true
           
           // Filter user matches and calculate wins
           let userMatches = allMatches.filter { match in
               match.allyTeams.contains { allyTeam in
                   allyTeam.players.contains { player in
                       player.name == username
                   }
               }
           }
           
           let totalWins = userMatches.filter { match in
               match.allyTeams.contains { allyTeam in
                   allyTeam.players.contains { player in
                       player.name == username && allyTeam.winningTeam
                   }
               }
           }.count
           
           // Calculate line chart data and update view model properties
           let lineChartData = await calculateLineChartData(for: username, matches: allMatches)
           self.lineChartData = lineChartData
           self.isLoading = false
           self.dataReceived = true
           
           // Update total games and wins count
           self.totalGames = allMatches.count
           self.winsCount = totalWins
       }
       
       private func calculateLineChartData(for username: String, matches: [MatchData]) async -> LineChartData {
           let currentDate = Date()
           
           var winsByMonth: [Int] = []
           var lossesByMonth: [Int] = []
           
           for i in 0..<4 { // Adjusted to include four months
               let startDate = Calendar.current.date(byAdding: .month, value: -i, to: currentDate)!
               let endDate = Calendar.current.date(byAdding: .month, value: -i+1, to: currentDate)!
               
               let matchesInRange = matches.filter {
                   $0.startTime >= startDate && $0.startTime < endDate
               }
               
               let totalWins = matchesInRange.filter { $0.allyTeams.contains { $0.players.contains { $0.name == username } && $0.winningTeam } }.count
               
               winsByMonth.append(totalWins)
               lossesByMonth.append(matchesInRange.count - totalWins)
           }
           
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MMM"
           //let currentMonth = dateFormatter.string(from: currentDate)
           let lastMonth = dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!)
           let twoMonthsAgo = dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: -2, to: currentDate)!)
           let threeMonthsAgo = dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: -3, to: currentDate)!)
           
           return LineChartData(xData: [threeMonthsAgo, twoMonthsAgo, lastMonth], yData: zip(winsByMonth.reversed(), lossesByMonth.reversed()).map { $0 })
       }
   }

   import Foundation

   // Structures for representing the JSON data

   // Top-level structure representing the entire JSON data
   struct MatchDataResponse: Codable {
       let totalResults: Int
       let page: Int
       let limit: Int
       let data: [MatchData]
   }

   struct MatchData: Codable {
       let id: String
       let startTime: Date
       let durationMs: Double // Ensure this property is defined as Double
       let map: Map
       let allyTeams: [AllyTeam]
       
       private enum CodingKeys: String, CodingKey {
           case id, startTime, durationMs, map = "Map", allyTeams = "AllyTeams"
       }
   }

   // Structure representing the map information
   struct Map: Codable {
       let fileName: String
       let scriptName: String
   }

   // Structure representing ally team data
   struct AllyTeam: Codable {
       let winningTeam: Bool
       let players: [Player]
       let AIs: [AI] // Assuming there could be AI players
       
       private enum CodingKeys: String, CodingKey {
           case winningTeam, players = "Players", AIs
       }
   }

   // Structure representing player data
   struct Player: Codable {
       let name: String
   }

   // Structure representing AI player data
   struct AI: Codable {
       // AI properties if any, not available in the provided JSON snippet
   }



   extension DateFormatter {
       static let iso8601Full: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
           return formatter
       }()
   }
