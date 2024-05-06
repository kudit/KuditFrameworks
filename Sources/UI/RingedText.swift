//
//  RingedText.swift
//  Tracker
//
//  Created by Ben Ku on 10/28/21.
//

#if canImport(SwiftUI)
import SwiftUI

public extension Text {
    func ringed() -> some View {
        GeometryReader { g in
            ZStack {
                let short = min(g.size.width, g.size.height)
                let stroke = short * 0.1
                Circle().strokeBorder(Color.accentColor, lineWidth: stroke) // 30
                //                let inset = CGFloat(150)
                let inset = stroke * 3
                self
                //                Text("\(Int(short))")
                    .font(.system(size:short))
                    .fontWeight(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .frame(maxWidth: g.size.width - inset,
                           maxHeight: g.size.height - inset)
                //                    .background(.pink)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        //        .background(.green)
    }
}

public struct RingedText_Previews: PreviewProvider {
    public static var previews: some View {
        VStack {
            Text("123")
                .ringed()
            HStack {
                Text("888")
                    .ringed()
                VStack {
                    Text("99")
                        .ringed()
                    HStack {
                        Text("10")
                            .font(.system(size: 100, weight: .light, design: .serif))
                            .fontWeight(.light)
                            .ringed()
                            .foregroundColor(.green)
                        VStack {
                            Text("0")
                                .ringed()
                            Text("999")
                                .ringed()
                        }
                    }
                }
            }
        }
    }
}
#endif
