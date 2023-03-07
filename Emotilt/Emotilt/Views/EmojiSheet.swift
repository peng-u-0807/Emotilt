//
//  EmojiSheet.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/07.
//

import SwiftUI

struct EmojiSheet: View {
    
    @Binding var selected: String
    
    @Environment(\.dismiss) private var dismiss
    
    let emojiList: [Int] = Array(0x1F600...0x1F64F)
    let layout = [GridItem(.flexible(), spacing: 16),
                  GridItem(.flexible(), spacing: 16),
                  GridItem(.flexible(), spacing: 16),
                  GridItem(.flexible())]
    
    var body: some View {
        VStack {
            Spacer().frame(height: 36)

            ScrollView {
                LazyVGrid(columns: layout, spacing: 16) {
                    ForEach(emojiList, id: \.self) { emoji in
                        if let _ = UnicodeScalar(emoji)?.properties.isEmoji {
                            Text(String(UnicodeScalar(emoji)!))
                                .font(.system(size: 32))
                                .onTapGesture {
                                    selected = String(UnicodeScalar(emoji)!)
                                    dismiss()
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct EmojiSheet_Previews: PreviewProvider {
    static var previews: some View {
        EmojiSheet(selected: .constant(""))
    }
}
