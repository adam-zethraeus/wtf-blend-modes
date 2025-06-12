import SwiftUI

extension BlendMode: @retroactive Identifiable {
  public var id: Self { self }
}

@available(macCatalyst 17.0, *)
@available(iOS 17.0, *)
@main
struct MyApp: App {

  var casesSets: [[(BlendMode, String)]] {
    stride(from: 0, to: cases.count, by: 5)
      .map { Array(cases[$0..<min($0+5, cases.count)]) }
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

  @State var fg: Color = Color(hex6: 0xFFDA2A)
  @State var bgsymbol: String = "square"
  @State var bgsymbolpresent: Bool = false
  @State var bg: Color = .black
  @State var fgmode: BlendMode = .normal
  @State var fgsymbol: String = "figure.walk.triangle.fill"
  @State var fgsymbolpresent: Bool = false
  @State var scale: BlendMode? = nil
  @State var clip: String? = nil
    var body: some Scene {
      WindowGroup {
        VStack {
          Grid {
            ForEach(0..<4) { x in
              GridRow(alignment: .bottom) {
                ForEach(casesSets[x], id: \.0) { pair in
                  VStack {
                    ZStack {
                      Image(systemName: bgsymbol)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundStyle(bg)
                        .padding(.bottom, 10)
                        .padding(.trailing, 10)
                      Image(systemName: fgsymbol)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundStyle(fg)
                        .blendMode(pair.0)
                        .padding(.top, 10)
                        .padding(.leading, 10)
                    }.compositingGroup()
                      .padding(4)
                      .background(content: {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                          .fill()
                          .foregroundStyle(Color.white.opacity(pair.0 == scale ? 1 : 0))
                            .betterShadow(elevation: pair.0 == scale ? 3.0 : 0.0, opacity: pair.0 == scale ? 0.2 : 0)
                      })
                      .scaleEffect(pair.0 == scale ? 2 : 1, anchor: .center)
                      .onTapGesture {
                        scale = scale == pair.0 ? nil : pair.0
                      }
                    Text(pair.1)
                      .font(.caption)
                      .monospaced()
                      .lineLimit(2, reservesSpace: true)
                      .opacity(pair.0 == scale ? 0 : 1)
                      .onTapGesture {
                        clip = clip ?? pair.1
                      }
                  }
                  .zIndex(pair.0 == scale ? 100 : 0)

                }
              }
            }
          }
          .animation(.bouncy, value: scale)
          Divider()
            HStack {
              VStack {
              Button {
                fgsymbolpresent = true
              } label: {

                  Image(systemName: fgsymbol)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 50, maxHeight: 50)
                    .foregroundStyle(fg)
                    .padding()
                    .betterShadow(elevation: 3, opacity: 0.2)
                }
              .buttonStyle(.plain)
              Text(fgsymbol).multilineTextAlignment(.center).font(.caption2).monospaced().lineLimit(2, reservesSpace: true)
                .onTapGesture {
                  clip = clip ?? fgsymbol
                }
              }
              .sheet(isPresented: $fgsymbolpresent) {
                SymbolPicker(symbol: $fgsymbol)
                  .tint(fg)
              }
              VStack {
                ColorPaletteView(color: $fg)
                  .frame(width: 50, height: 50)
                  .padding()
                  .overlay {
                    Text("fg").monospaced().foregroundStyle(.foreground)
                  }
                Text(bg.hexString).multilineTextAlignment(.center).font(.caption2).monospaced().lineLimit(2, reservesSpace: true)
                  .onTapGesture {
                    clip = clip ?? bg.hexString
                  }
              }

              Spacer()

              VStack {
                ColorPaletteView(color: $bg)
                  .frame(width: 50, height: 50)
                  .padding()
                  .overlay {
                    Text("bg").monospaced().foregroundStyle(.background)
                  }
                Text(fg.hexString).multilineTextAlignment(.center).font(.caption2).monospaced().lineLimit(2, reservesSpace: true)
                  .onTapGesture {
                    clip = clip ?? fg.hexString
                  }
              }
              VStack {
              Button {
                bgsymbolpresent = true
              } label: {

                  Image(systemName: bgsymbol)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 50, maxHeight: 50)
                    .padding()
                    .foregroundStyle(bg)
                    .betterShadow(elevation: 3, opacity: 0.2)
                }
                Text(bgsymbol).multilineTextAlignment(.center).font(.caption2).monospaced().lineLimit(2, reservesSpace: true)
                  .onTapGesture {
                    clip = clip ?? bgsymbol
                  }
              }
              .buttonStyle(.plain)

              .sheet(isPresented: $bgsymbolpresent) {
                SymbolPicker(symbol: $bgsymbol)
                  .tint(bg)
              }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top)
            .safeAreaInset(edge: .bottom) {

              ZStack {
                Text("  ").lineLimit(3, reservesSpace: true).hidden()
                if let clip {
                  Label(clip, systemImage: "scissors").font(.caption).monospaced()
                    .foregroundStyle(.background)
                    .padding()
                    .background {
                      RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.primary)
                    }
                    .transition(.scale)
                }
              }
              .animation(.bouncy, value: clip)
              .ignoresSafeArea()
            }
          .task(id: clip) {
            if let clip {
              UIPasteboard.general.string = clip
            }
            try? await Task.sleep(for: .seconds(1.5))
            if !Task.isCancelled {
              clip = nil
            }
          }
        }
        .padding(.horizontal)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .ignoresSafeArea()
          .background {
            Rectangle()
              .fill(.thickMaterial)
              .ignoresSafeArea()
          }
        }
    }
}

extension Color {
  init(hex6: UInt32, opacity: Double = 1) {
    let divisor = Double(0xFF)
    let red = Double((hex6 & 0xFF0000) >> 16) / divisor
    let green = Double((hex6 & 0x00FF00) >> 8) / divisor
    let blue = Double(hex6 & 0x0000FF) / divisor

    self.init(red: red, green: green, blue: blue, opacity: opacity)
  }
  public var hexString: String {
    var red: CGFloat = .zero
    var green: CGFloat = .zero
    var blue: CGFloat = .zero
    var alpha: CGFloat = .zero
    self.toUIColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      return [red, green, blue, alpha]
          .map { channelProportion in
              String(
                  format: "%02lx",
                  Int(round(channelProportion * 255.0))
              )
          }
          .reduce("#", +)
  }
}
