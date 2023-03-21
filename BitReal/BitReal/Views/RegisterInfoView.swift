//
//  RegisterInfoView.swift
//  BitReal
//
//  Created by Pinru Chen on 2/27/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RegisterInfoView: View {
    var email: String
    
    @State private var username = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var registerSuccess = false
    
    var body: some View {
        VStack{
            Text("Register")
                .padding(.top, 50)
                .font(.system(size: 40))
                .fontWeight(.bold)
                .offset(x: -90, y: -130)
            
            TextField("Username", text: $username)
                .padding()
                .frame(width: 350)
                .background(Color.white.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                .offset(y: -155)
                .padding(.top, 30)
            
            TextField("Full Name", text: $fullName)
                .padding()
                .frame(width: 350)
                .background(Color.white.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                .offset(y: -170)
                .padding(.top, 30)
            
            SecureField("Password", text: $password)
                .padding()
                .frame(width: 350)
                .background(Color.white.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                .offset(y: -180)
                .padding(.top, 20)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .frame(width: 350)
                .background(Color.white.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                .offset(y: -190)
                .padding(.top, 20)
            
            VStack{
                Text("By signing up, you agree to BitReal’s Terms of Service and Privacy Policy.")
//                    .multilineTextAlignment(.center)
                    .frame(alignment: .center)
                    .font(.system(size: 13))
                    .offset(y: -160)
            }
            Button(action: {
                if confirmPassword != password{
                    print("Please enter correct password!")
                }else{
                    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        if let error = error as NSError? {
                            print("\(error.localizedDescription)")
                        } else {
                            registerSuccess = true
                        }
                    }
                }
            }){
                NavigationLink(destination: Navbar()) {
                    CustomButton(color: .white, outline: true, label: "SIGN UP")
                }
                .disabled(!registerSuccess)
            }
        }
    }
}

struct RegisterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterInfoView(email: "example@test.com")
    }
}
