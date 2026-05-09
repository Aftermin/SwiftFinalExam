//
//  ExpandedNavigationTitle.swift
//  FPE
//

import SwiftUI

struct ExpandedNavigationTitle: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 34, weight: .medium))
                .fontWidth(.expanded)
                .bold()
                .fixedSize()
            Spacer()
        }
    }
}
