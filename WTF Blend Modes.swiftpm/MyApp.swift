import SwiftUI

extension BlendMode: @retroactive Identifiable {
  public var id: Self { self }
}

@available(macCatalyst 17.0, *)
@main
struct MyApp: App {

  var casesSets: [[(BlendMode, String)]] {
    stride(from: 0, to: cases.count, by: 7)
      .map { Array(cases[$0..<min($0+7, cases.count)]) }
  }

  var cases: [(BlendMode, String)] = [
    (.normal,"normal"),
    (.multiply,"multiply"),
    (.screen,"screen"),
    (.overlay,"overlay"),
    (.darken,"darken"),
    (.lighten,"lighten"),
    (.colorDodge,"colorDodge"),
    (.colorBurn,"colorBurn"),
    (.softLight,"softLight"),
    (.hardLight,"hardLight"),
    (.difference,"difference"),
    (.exclusion,"exclusion"),
    (.hue,"hue"),
    (.saturation,"saturation"),
    (.color,"color"),
    (.luminosity,"luminosity"),
    (.sourceAtop,"sourceAtop"),
    (.destinationOver,"destinationOver"),
    (.destinationOut,"destinationOut"),
    (.plusDarker,"plusDarker"),
    (.plusLighter,"plusLighter")
  ]

  @State var fgitem: Item = .circle
  @State var fg: Color = .white
  @State var bgitem: Item = .square
  @State var bg: Color = .black
  @State var fgmode: BlendMode = .normal
    var body: some Scene {
      WindowGroup {
        NavigationSplitView {
            VStack(alignment: .center) {
              ColorPaletteView(color: $fg)
                .padding()
              BGPicker(item: $fgitem)
            }
            .fixedSize(horizontal: true, vertical: true)
            .padding()
            Divider()
            VStack(alignment: .center) {
              ColorPaletteView(color: $bg)
                .padding()
              BGPicker(item: $bgitem)
            }
            .fixedSize(horizontal: true, vertical: true)
            .padding()

          Spacer()
        } detail: {
          Grid {
            ForEach(0..<3) { x in
              GridRow(alignment: .bottom) {
                ForEach(casesSets[x], id: \.0) { pair in
                  VStack {
                    Text("")
                    ZStack {
                      switch bgitem {
                      case .circle:
                        Circle()
                          .aspectRatio(1, contentMode: .fit)
                          .foregroundStyle(bg)
                      case .roundedSquare:
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                          .aspectRatio(1, contentMode: .fit)
                          .foregroundStyle(bg)
                      case .square:
                        Rectangle()
                          .aspectRatio(1, contentMode: .fit)
                          .foregroundStyle(bg)
                      }
                      switch fgitem {
                      case .circle:
                        Circle()
                          .aspectRatio(1, contentMode: .fit)
                          .foregroundStyle(fg)
                          .blendMode(pair.0)
                      case .roundedSquare:
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                          .aspectRatio(1, contentMode: .fit)
                          .foregroundStyle(fg)
                          .blendMode(pair.0)
                      case .square:
                        Rectangle()
                          .aspectRatio(1, contentMode: .fit)
                          .foregroundStyle(fg)
                          .blendMode(pair.0)
                      }
                    }
                    Text(pair.1)
                      .font(.caption)
                      .monospaced()
                      .lineLimit(2, reservesSpace: true)
                  }
                }
              }
            }
          }
          .padding()
          .background {
            Rectangle()
              .fill(.thickMaterial)
            .shadow(radius: 5)
          }
          .padding()
        }
      }
    }
}
