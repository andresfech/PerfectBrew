import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("PerfectBrew")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                NavigationLink(destination: BrewSetupScreen()) {
                    Text("Start New Brew")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: BrewHistoryScreen()) {
                    Text("Brew History")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
