//
//  ResetPasswordView.swift
//  Liquid
//
//  Created by Alberto Dominguez on 2/18/22.
//

import SwiftUI

struct ResetPasswordView: View {
    @State var showAlert = false
    @State var errString: String?
    @State var mail = ""
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView{
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    
                    TextField (
                        "Enter Email Address", text: self.$mail)
                        .foregroundColor(.black)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }.padding()
                
                Divider()
                
                Button(action: {
                    guard !mail.isEmpty else {
                        return
                    }
                    viewModel.resetPassword(email: mail) { (result) in
                        switch result {
                        case .failure(let error):
                            self.errString = error.localizedDescription
                        case .success (_):
                            break
                        }
                        self.showAlert = true
                    }
                }) {
                    Text("Reset Password")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
                }.background(Color(.green))
                .cornerRadius(8)
                .padding(.bottom, -40)
                .shadow(radius: 15)
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Password Reset"), message: Text(self.errString ?? "Success. Reset email sent successfully. Check your email"), dismissButton: .default(Text("Ok")) {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
