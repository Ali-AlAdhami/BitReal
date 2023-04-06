//
//  PostsRowView.swift
//  BitReal
//
//  Created by Ali Al-Adhami on 2/24/23.
//

import SwiftUI
import Kingfisher
import Firebase

struct PostsRowView: View {
    
    let post: Post
    @State var isLiked: Bool = false
    @State var likeCount: Int = 0
    
    var body: some View {
        // profile image, user info, and post
        VStack (alignment: .leading) {
            if let user = post.user{
                HStack (alignment: .top, spacing: 12) {
                    // user image
                    KFImage(URL(string: user.profileImageURL))
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color(.systemBlue))
                        .cornerRadius(30)
                    VStack (alignment: .leading) {
                        HStack {
                            // public name
                            Text(user.fullname)
                                .font(.subheadline).bold()
                            // username
                            Text("@\(user.username)")
                                .foregroundColor(Color("gray"))
                                .font(.caption)
                            // how long since posted
                            Text("\(daysSinceTimestamp(_: post.timestamp))")
                                .foregroundColor(Color("gray"))
                                .font(.caption)
                        }
                        // post content
                        Text(post.caption)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            // like and comment buttons
            HStack {
                Spacer()
                Button(action: {
                    isLiked.toggle()
                    likeCount = max(0, likeCount + (isLiked ? 1 : -1))
                    updatePostLikes(post: post, likeCount: likeCount)
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isLiked ? .red : .gray)
                }
                .onAppear {
                    isLiked = UserDefaults.standard.bool(forKey: "\(String(describing: post.id))_isLiked")
                }
                
                Button (action: { navigateToPostDetail(post: post) }) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 15)
            .padding(.bottom, 5)
            Divider()
        }
        .padding()
    }
    
    // update likes in firebase
    private func updatePostLikes(post: Post, likeCount: Int) {
        let postRef = Firestore.firestore().collection("posts").document(post.id!)
        postRef.updateData(["likes": likeCount]) { error in
            if let error = error {
                print("ERROR: failed updating post likes. Error is: \(error.localizedDescription)")
            } else {
                print("Updated post likes")
            }
        }
        UserDefaults.standard.set(isLiked, forKey: "\(String(describing: post.id))_isLiked")
    }
    
    private func navigateToPostDetail(post: Post) {
        let postDetailView = PostDetailView(post: post)
        let hostingController = UIHostingController(rootView: postDetailView)
        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true)
    }
    
    // given a Timestamp, returns how long since it's been created
    private func daysSinceTimestamp(_ timestamp: Timestamp) -> String {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: timestamp.dateValue())
        let date2 = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day, .hour, .minute], from: date1, to: date2)
        
        if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute {
            return "\(minutes)m"
        } else {
            return "just now"
        }
    }

}

