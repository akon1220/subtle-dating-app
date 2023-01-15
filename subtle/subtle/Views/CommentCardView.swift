//
//  CommentView.swift
//  subtle
//
//  Created by Jimin Cheon on 3/22/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CommentCardView: View {
    var comment: CommentModel
    
    var body: some View {
        HStack(spacing: 12) {
            //Maybe profile photo here
            VStack (alignment: .leading, spacing: 4) {
                Text(comment.username)
                    .font(.subheadline).bold()
                    .foregroundColor(.black)
                
                Text(comment.comment)
                    .font(.subheadline)
            }
            
            
            Spacer()
            
            Text((Date(timeIntervalSince1970: comment.date)).timeAgo() + " ago").font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}


