//
//  ContentView.swift
//  Shared
//
//  Created by Alberto Dominguez on 2/12/22.
//
import SwiftUI
import FirebaseAuth
import AuthenticationServices

class AppViewModel: ObservableObject {
    let auth = Auth.auth()
    @Published var signedIn = false
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil,error == nil else { return }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil,error == nil else { return }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func resetPassword(email: String, resetCompletion: @escaping (Result< Bool, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email, completion: { (error) in
            if let error = error {
                resetCompletion(.failure(error))
            }
            else {
                resetCompletion(.success(true))
            }
        })
    }
    
    func signOut() {
        try? auth.signOut()
        
        self.signedIn = false
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color("Color"), Color("Color-1")]), startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            if viewModel.signedIn {
                tabs()
            }
            else{
                Login_Signup()
            }
        }.onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}

struct tabs: View {
    @State private var selection = 2
    var body: some View {
        TabView(selection: $selection){
            JournalView()
                .tabItem {
                    Text("Journal")
                    Image(systemName: "book.fill")
                }.tag(1)
            HomeView()
                .tabItem {
                    Text("Home")
                    Image(systemName: "house.fill")
                }.tag(2)
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape.fill")
                }.tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).preferredColorScheme(.light)
    }
}
