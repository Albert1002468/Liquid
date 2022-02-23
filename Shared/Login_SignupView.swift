//
//  Login:Signup.swift
//  Liquid
//
//  Created by Alberto Dominguez on 2/16/22.
//
import SwiftUI
import AuthenticationServices
import Firebase
import GoogleSignIn

struct AppleUser: Codable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    
    init?(credentials: ASAuthorizationAppleIDCredential) {
        guard
            let firstName = credentials.fullName?.givenName,
            let lastName = credentials.fullName?.familyName,
            let email = credentials.email
        else { return nil }
        
        self.userId = credentials.user
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

struct Login_Signup: View {
    @State var isLoading: Bool = false
    var body: some View {
        ZStack{

            if isLoading {
                Color.black
                    .opacity(0.25)
                    .ignoresSafeArea()
             
                ProgressView()
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .cornerRadius(10)
             }
            if UIScreen.main.bounds.height > 800 {
                Home()
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    Home()
                }
            }
        }
    }
}

struct Home: View {
    @State var index = 0
    @State var isModal: Bool = false
    @State var isLoading: Bool = false
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack {
            Text("LIQUID")
                .fontWeight(.bold)
                .padding(.vertical,20)
                .font(Font.system(size: 50))
                .foregroundColor(.green)

            HStack {
                Button(action: {
                    self.index = 0
                }) {
                    Text("Existing User")
                    .foregroundColor(self.index == 0 ? .black : .white)
                    .fontWeight(.bold)
                    .padding (.vertical, 10)
                    .frame (width: (UIScreen.main.bounds.width - 50)/2)
                    }.background(self.index == 0 ? Color.white : Color.clear)
                    .clipShape(Capsule())
                            
                Button(action: {
                    self.index = 1
                }) {
                    Text("New User")
                    .foregroundColor(self.index == 1 ? .black : .white)
                    .fontWeight(.bold)
                    .padding (.vertical, 10)
                    .frame (width: (UIScreen.main.bounds.width - 50)/2)
                    }.background(self.index == 1 ? Color.white : Color.clear)
                    .clipShape(Capsule())
            }.background(Color.black.opacity(0.1))
            .clipShape(Capsule())
            .padding(.top,25)
            
            if self.index == 0 { Login() }
            else { SignUp() }
            
            if self.index == 0 {
                Button("Reset Password?") {
                    self.isModal = true
                }.foregroundColor(.black)
                .padding()
                .sheet(isPresented: $isModal, content: {
                    ResetPasswordView()
                })
            }
            
            HStack(spacing: 15) {
                Color.black.opacity(0.7)
                .frame(width: 35, height: 1)
                
                Text("Or")
                .fontWeight(.bold)
                .foregroundColor(.black)
                
                Color.black.opacity(0.7)
                .frame(width: 35, height: 1)
            }.padding(.top, 10)
            
            VStack {
                SignInWithAppleButton(.continue, onRequest: appleConfigure, onCompletion: appleHandle)
                    .frame(width: UIScreen.main.bounds.width - 140, height: 44)
                    .padding()
                    .signInWithAppleButtonStyle(.black)
                
                Button(action: {
                    googleHandle()
                }) {
                    HStack{
                        Spacer()

                        Image("btn_google_light_normal_ios")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                        Text("Sign in with Google")
                            .foregroundColor(.black).opacity(0.7)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                    }
                }.frame(width: UIScreen.main.bounds.width - 140, height: 44)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 10)
            }
        }.padding()
    }
    
    func appleConfigure(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        //request.nonce = ""
    }
    
    func appleHandle(_ authResult: Result<ASAuthorization, Error>) {
        switch authResult {
           case .success(let auth):
               print(auth)
               switch auth.credential {
               case let appleIdCredentials as ASAuthorizationAppleIDCredential:
                   if let appleUser = AppleUser(credentials: appleIdCredentials),
                      let appleUserData = try? JSONEncoder().encode(appleUser) {
                       UserDefaults.standard.setValue(appleUserData, forKey: appleUser.userId)
                       
                       print("saved apple user", appleUser)
                       
                   }
                   else {
                       print("missing some fields", appleIdCredentials.email ?? "" , appleIdCredentials.fullName ?? "" , appleIdCredentials.user)
                       
                       guard
                           let appleUserData = UserDefaults.standard.data(forKey: appleIdCredentials.user),
                           let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData)
                       else { return }
                       
                       print(appleUser)
                       
                       withAnimation{
                           viewModel.signedIn = true
                       }
                   }
                   
               default:
                   print(auth.credential)
               }
               
           case .failure(let error):
               print(error)
        }
    }
    
    func googleHandle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        isLoading = true
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()){
            [self] user, err in
            
            if let error = err {
                isLoading = false
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { result, err in
                
                isLoading = false

                if let error = err {
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else{
                    return
                }
                
                print(user.displayName ?? "Success!")
                
                withAnimation{
                    viewModel.signedIn = true
                }
            }
        }
    }
}

struct Login: View {
    @State var isSecure: Bool = true
    @State var mail = ""
    @State var pass = ""
    @State var showAlert = false
    @State var errString: String?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    
                    TextField (
                        "Enter Email Address", text: self.$mail)
                        .foregroundColor(.black)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }.padding(.vertical, 20)
                
                Divider()
                
                HStack(spacing: 15) {
                    Image(systemName: "lock")
                        .resizable()
                        .frame(width: 15, height:18)
                        .foregroundColor(.black)
                    
                    if isSecure {
                        SecureField (
                            "Enter Password", text: self.$pass)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            isSecure.toggle()
                        }) {
                            Image(systemName: "eye.slash")
                            .foregroundColor(.gray)
                        }
                    }
                    else {
                        TextField (
                            "Enter Password", text: self.$pass)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            isSecure.toggle()
                        }) {
                            Image(systemName: "eye")
                            .foregroundColor(.gray)
                        }
                    }
                }.padding(.vertical, 20)
            }.padding(.vertical)
            .padding(.top,25)
            .padding(.bottom,40)
            .padding(.horizontal,20)
            .background(Color.white)
            .cornerRadius(10)
            
            Button(action: {
                guard !mail.isEmpty, !pass.isEmpty else {
                    return
                }
                viewModel.signIn(email: mail, password: pass)
            }) {
                Text("LOGIN")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(width: UIScreen.main.bounds.width - 100)
            }.background(Color(.green))
            .ignoresSafeArea()
            .cornerRadius(8)
            .offset(y:-40)
            .padding(.bottom, -40)
            .shadow(radius: 15)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Log In"), message: Text(self.errString ?? "Success."), dismissButton: .default(Text("Ok")) {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

struct SignUp: View {
    @State var mail = ""
    @State var pass = ""
    @State var repass = ""
    @State var showAlert = false
    @State var errString: String?
    @State var isSecure: Bool = true
    @State var isSecure2: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    
                    TextField(
                        "Enter Email Address", text: self.$mail)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .foregroundColor(.black)
                }.padding(.vertical, 20)
                
                Divider()
                
                HStack(spacing: 15) {
                    Image(systemName: "lock")
                        .resizable()
                        .frame(width: 15, height:18)
                        .foregroundColor(.black)
                    
                    if isSecure {
                        SecureField (
                            "Enter Password", text: self.$pass)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            isSecure.toggle()
                        }) {
                            Image(systemName: "eye.slash")
                            .foregroundColor(.gray)
                        }
                    }
                    else {
                        TextField (
                            "Enter Password", text: self.$pass)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            isSecure.toggle()
                        }) {
                            Image(systemName: "eye")
                            .foregroundColor(.gray)
                        }
                    }
                }.padding(.vertical, 20)
                
                Divider()
                
                HStack(spacing: 15) {
                    Image(systemName: "lock")
                        .resizable()
                        .frame(width: 15, height:18)
                        .foregroundColor(.black)
                    
                    if isSecure2 {
                        SecureField (
                            "Re-Enter Password", text: self.$repass)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            isSecure2.toggle()
                        }) {
                            Image(systemName: "eye.slash")
                            .foregroundColor(.gray)
                        }
                    }
                    else {
                        TextField (
                            "Re-Enter Password", text: self.$repass)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            isSecure2.toggle()
                        }) {
                            Image(systemName: "eye")
                            .foregroundColor(.gray)
                        }
                    }
                }.padding(.vertical, 20)
            }.padding(.vertical)
                .padding(.top,25)
                .padding(.bottom,40)
                .padding(.horizontal,20)
                .background(Color.white)
                .cornerRadius(10)
            
            Button(action: {
                guard !mail.isEmpty, !pass.isEmpty, !repass.isEmpty, pass == repass else {
                    
                    return
                }
                viewModel.signUp(email: mail, password: pass, completion: )
            }) {
                Text("SIGNUP")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(width: UIScreen.main.bounds.width - 100)
            }.background(Color(.green)).cornerRadius(8)
            .offset(y:-40)
            .padding(.bottom, -40)
            .shadow(radius: 15)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Sign Up"), message: Text(self.errString ?? "Success."), dismissButton: .default(Text("Ok")) {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

struct Login_Signup_Previews: PreviewProvider {
    static var previews: some View {
        Login_Signup()
    }
}

extension View {
    func getRootViewController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return .init() }
        guard let root = screen.windows.first?.rootViewController
        else { return .init() }
        return root
    }
}
