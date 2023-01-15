//
//  TagView.swift
//  subtle
//
//  Created by Akira Tou on 2022/03/21.
//

import SwiftUI

//Custom View
struct TagView: View {
    var maxLimit: Int
    @Binding var tags: [String]
    
    var fontSize: CGFloat = 16
    
    //Adding Geometry Effect to Tag..
    @Namespace var animation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(tags, id: \.self) { tag in
//                            HStack(spacing: 6) {
//                                ForEach(rows) { row in
                        //                                    //Row View...
                                    RowView(tag: tag)
//                                }
                            }
      

                }
                .frame(width: UIScreen.main.bounds.width - 80, alignment: .leading)
                .padding(.vertical)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
    //        .background(
    //
    //        RoundedRectangle(cornerRadius: 8)
    //            .strokeBorder(Color("Tag").opacity(0.15), lineWidth: 1)
    //        )
            //Animation
            .animation(.easeInOut, value: tags)
//            .overlay(
//                //Limit..
//                Text("\(getSize(tags: tags))/\(maxLimit)")
//                    .font(.system(size: 13, weight: .semibold))
//                    .padding(12),
//                alignment: .bottomTrailing
//            )
        }
    }
        
    @ViewBuilder
    func RowView(tag: String) -> some View {
            Text(tag)
                .font(.system(size: fontSize))
                .padding(.horizontal, 14)
                .padding(.vertical)
                .background(
                    Capsule().fill(Color.lightOrange)
                )
                .lineLimit(1)
                .onTapGesture {
                    //deleting...
                    tags.remove(at: getIndex(tag: tag))
            }
                .matchedGeometryEffect(id: tag, in: animation)
        }

        
    func getIndex(tag: String) -> Int {
        let idx = tags.firstIndex {currTag in
            return tag == currTag
        } ?? 0
        
        return idx
    }
        

}


struct TagView_Previews: PreviewProvider {
    @State static var tags: [String] = []
    static var previews: some View {
        TagView(maxLimit: 100, tags: $tags)
    }
}

//Global Function
//func addTag(text: String, fontSize: CGFloat, maxLimit: Int, completion: @escaping (Bool, Tag) -> ()) {
//
//    let tag = text
//
//    completion(true, tag)
//}


