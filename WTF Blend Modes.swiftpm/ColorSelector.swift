//
//  ColorSelector.swift
//  WTF Blend Modes
//
//  Created by adamz on 2025-06-11.
//


import SwiftUI
import SwiftUICore
@available(macCatalyst 17.0, *)
public struct ColorSelector: View {
  @ObservedObject var viewModel: ColorSelectionModel = .init()
  @Environment(\.pointSize) private var pointSize
  @Binding var selection: Color?
  @State private var popover: Bool = false
  var title: LocalizedStringKey?
  var arrowEdge: Edge? = nil
  public init(
    _ title: LocalizedStringKey? = nil, selection: Binding<Color?>, arrowEdge: Edge? = nil
  ) {
    self.title = title
    self.arrowEdge = arrowEdge
    self._selection = selection
  }

  public init(
    _ title: LocalizedStringKey? = nil, uiColor: Binding<UIColor?>, arrowEdge: Edge? = nil
  ) {
    self.title = title
    self.arrowEdge = arrowEdge
    self._selection = Binding<Color?> {
      if let uiColor = uiColor.wrappedValue {
        return Color(uiColor)
      } else {
        return nil
      }
    } set: { newValue in
      uiColor.wrappedValue = newValue?.toUIColor
    }
  }

  @State private var saturation: CGFloat = 1.0
  @State private var brightness: CGFloat = 1.0
  @State private var hue: CGFloat = 0.0
  @State private var alpha: CGFloat = 1.0

  public var body: some View {
    HStack {
      if let title {
        Text(title)
        Spacer()
      }
      Button(
        action: {
          popover = true
        },
        label: {
          ZStack {
            if let selection, selection != .clear {
              RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(selection)
                .frame(width: 38, height: 17)
                .overlay(
                  RoundedRectangle(cornerRadius: 2.5, style: .continuous).stroke(lineWidth: 1)
                    .opacity(0.25)
                )
                .background(
                  CheckerboardBackground(squareSize: 5)
                    .opacity(0.25)
                )
                .mask(RoundedRectangle(cornerRadius: 2.5, style: .continuous))
                .padding([.leading, .trailing], -5).padding([.top, .bottom], 2)
            } else {
              RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(.white)
                .frame(width: 38, height: 17)
                .overlay(
                  ZStack {
                    RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                      .stroke(lineWidth: 1).opacity(0.25)
                    Rectangle()
                      .fill(.red)
                      .frame(height: 1)
                      .rotationEffect(Angle(degrees: -22))
                  }
                )
                .mask(RoundedRectangle(cornerRadius: 2.5, style: .continuous))
                .padding([.leading, .trailing], -5).padding([.top, .bottom], 2)
            }
          }
        }
      )
      .frame(width: 44, height: 23)
      .popover(isPresented: $popover, arrowEdge: arrowEdge) {
        ZStack {
          Color(uiColor: UIColor.systemBackground).scaleEffect(1.5)
          Sketch(
            hue: $hue,
            saturation: $saturation,
            brightness: $brightness,
            alpha: $alpha
          )
          .showsAlpha($viewModel.showsAlpha)
          .onChange(
            of: hue, initial: false,
            { old, val in
              changeColor()
            }
          )
          .onChange(
            of: brightness, initial: false,
            { old, val in
              changeColor()
            }
          )
          .onChange(
            of: saturation, initial: false,
            { old, val in
              changeColor()
            }
          )
          .onChange(
            of: alpha, initial: false,
            { old, val in
              changeColor()
            })
        }
        .frame(width: 180, height: 250)
        .onAppear {
          let selection = selection ?? Color.clear
          hue = selection.hue
          saturation = selection.saturation
          brightness = selection.brightness
          alpha = selection.alpha
        }
      }
    }
  }
  private func changeColor() {
    selection = Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
  }

  public func showsAlpha(_ value: Bool) -> ColorSelector {
    viewModel.showsAlpha = value
    return self as ColorSelector
  }
  public func showsAlpha(_ value: Binding<Bool>) -> ColorSelector {
    viewModel.showsAlpha = value.wrappedValue
    return self as ColorSelector
  }
}

#if canImport(SwiftUI)
  import SwiftUI

  private struct SwatchColorsKey: EnvironmentKey {
    static let defaultValue: [UIColor] = defaultSwatchColors
  }
  extension EnvironmentValues {
    public var swatchColors: [UIColor] {
      get { self[SwatchColorsKey.self] }
      set { self[SwatchColorsKey.self] = newValue }
    }
  }

  private struct PointSizesKey: EnvironmentKey {
    static let defaultValue: CGSize = .init(width: 10, height: 10)
  }
  extension EnvironmentValues {
    public var pointSize: CGSize {
      get { self[PointSizesKey.self] }
      set { self[PointSizesKey.self] = newValue }
    }
  }

  private struct CornerSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 5
  }
  extension EnvironmentValues {
    public var cornerSize: CGFloat {
      get { self[CornerSizeKey.self] }
      set { self[CornerSizeKey.self] = newValue }
    }
  }
#endif

class ColorSamplerViewModel: ObservableObject {
  @Published var size: CGFloat = 23
}

public struct ColorSampler: View {
  @ObservedObject var viewModel = ColorSamplerViewModel()
  @Environment(\.cornerSize) private var cornerSize
  @Binding var color: Color
  var onColorSampler: ((UIColor) -> Void)?
  @State var uiColor: Color?
  public init(color: Binding<Color>, onColorSampler: ((UIColor) -> Void)? = nil) {
    self._color = color
    self.onColorSampler = onColorSampler
    self.uiColor = color.wrappedValue
  }
  public var body: some View {
    Button(
      action: {

      },
      label: {
        ZStack {
          color
            .frame(width: viewModel.size, height: viewModel.size)
            .clipShape(
              RoundedRectangle(cornerRadius: cornerSize * 0.6)
            )
            .overlay(
              RoundedRectangle(cornerRadius: cornerSize * 0.6)
                .stroke(Color.secondary.opacity(0.46), lineWidth: 1)
            )
            .background(
              CheckerboardBackground(squareSize: 5)
                .clipShape(RoundedRectangle(cornerRadius: cornerSize * 0.6))
                .opacity(0.25)
            )

          Image(systemName: "eyedropper.full")
            .font(.system(size: viewModel.size * 0.6))
            .foregroundStyle(color.contrastingColor() ?? Color.secondary)
        }
      }
    )
    .buttonStyle(.plain)
  }

  public func rectSize(_ value: CGFloat) -> ColorSampler {
    viewModel.size = value
    return self as ColorSampler
  }
  public func rectSize(_ value: Binding<CGFloat>) -> ColorSampler {
    viewModel.size = value.wrappedValue
    return self as ColorSampler
  }
}

public let defaultSwatchColors: [UIColor] = [
  UIColor(hue: 0.999, saturation: 0.857, brightness: 0.878, alpha: 1.0),
  UIColor(hue: 0.066, saturation: 1.000, brightness: 0.980, alpha: 1.0),
  UIColor(hue: 0.121, saturation: 0.976, brightness: 0.969, alpha: 1.0),
  UIColor(hue: 0.247, saturation: 0.981, brightness: 0.827, alpha: 1.0),
  UIColor(hue: 0.462, saturation: 0.679, brightness: 0.843, alpha: 1.0),
  UIColor(hue: 0.547, saturation: 0.800, brightness: 1.000, alpha: 1.0),
  UIColor(hue: 0.573, saturation: 0.984, brightness: 1.000, alpha: 1.0),
  UIColor(hue: 0.703, saturation: 0.788, brightness: 1.000, alpha: 1.0),
  UIColor(hue: 0.797, saturation: 0.862, brightness: 0.878, alpha: 1.0),
  UIColor(hue: 0.597, saturation: 0.099, brightness: 0.475, alpha: 1.0),
  UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.1),
  UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.25),
  UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.5),
  UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.75),
  UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 1.0),
  UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0),
]

@available(macCatalyst 17.0, *)
public struct Swatch: View {
  @Environment(\.swatchColors) private var swatchColors
  @State private var width: CGFloat = 0
  var uiColor: UIColor? = UIColor.clear
  var size: CGSize = .init(width: 14, height: 14)
  var spacing: CGFloat = 4
  var onColorSelected: ((UIColor) -> Void)?
  public init(
    uiColor: UIColor? = UIColor.clear,
    size: CGSize = .init(width: 14, height: 14),
    spacing: CGFloat = 4,
    onColorSelected: ((UIColor) -> Void)? = nil
  ) {
    self.width = width
    self.uiColor = uiColor
    self.size = size
    self.spacing = spacing
    self.onColorSelected = onColorSelected
  }
  public var body: some View {
    ZStack {
      Color.clear
        .frame(height: 0)
        .frame(maxWidth: .infinity)
        .background(
          GeometryReader { geometry in
            Color.clear.preference(key: WidthPreferenceKey.self, value: geometry.size.width)
          }
        )
      LazyVGrid(
        columns: makeGridItems(for: width),
        spacing: spacing
      ) {
        ForEach(swatchColors, id: \.self) { item in
          Button(
            action: {
              onColorSelected?(item)
            },
            label: {
              let active = item.isEqual(to: self.uiColor)
              let border = borderColor(uiColor: item)
              RoundedRectangle(cornerRadius: size.width * 0.3)
                .fill(Color(uiColor: item))
                .stroke(active ? Color.accentColor : Color.clear, lineWidth: 2)
                .stroke(border.opacity(0.13), lineWidth: 1)
                .frame(width: size.width, height: size.height)
                .background(
                  Group {
                    if item.alpha < 1 {
                      CheckerboardBackground(squareSize: size.height / 2)
                        .clipShape(RoundedRectangle(cornerRadius: size.width * 0.3))
                        .opacity(0.25)
                    }
                  }
                )
            }
          )
          .buttonStyle(.plain)
        }
      }
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .frame(minHeight: size.height)
    .onPreferenceChange(WidthPreferenceKey.self) { newWidth in
      width = newWidth
    }
  }

  private func borderColor(uiColor: UIColor) -> Color {
    guard let color = uiColor.contrastingColor() else {
      return Color.secondary
    }
    return Color(uiColor: color)
  }

  private func makeGridItems(for width: CGFloat) -> [GridItem] {
    let totalItemWidth = size.width + spacing
    let maxColumns = max(1, Int(width / totalItemWidth))
    return Array(repeating: GridItem(.flexible(), spacing: spacing), count: maxColumns)
  }
}

struct WidthPreferenceKey: @preconcurrency PreferenceKey {
  @MainActor static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}

class ColorSelectionModel: ObservableObject {
  @Published var showsAlpha: Bool = true
}

@available(macCatalyst 17.0, *)
public struct Sketch: View {
  @ObservedObject var viewModel: ColorSelectionModel = .init()
  @Environment(\.pointSize) private var pointSize
  @Binding var hue: CGFloat
  @Binding var saturation: CGFloat
  @Binding var brightness: CGFloat
  @Binding var alpha: CGFloat
  public init(
    hue: Binding<CGFloat>,
    saturation: Binding<CGFloat>,
    brightness: Binding<CGFloat>,
    alpha: Binding<CGFloat>,
  ) {
    self._hue = hue
    self._saturation = saturation
    self._brightness = brightness
    self._alpha = alpha
  }
  public var body: some View {
    VStack(spacing: 10) {
      Saturation(
        saturation: $saturation,
        brightness: $brightness,
        hue: hue
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      HStack {
        VStack {
          HueSlider(hue: $hue)
          if viewModel.showsAlpha == true {
            AlphaSlider(
              alpha: $alpha,
              hue: hue,
              saturation: saturation,
              brightness: brightness
            )
          }
        }
        let color = Color(
          hue: hue,
          saturation: saturation,
          brightness: brightness,
          opacity: alpha
        )
        let bind = Binding(
          get: { color },
          set: { value in
            hue = value.hue
            saturation = value.saturation
            brightness = value.brightness
            alpha = value.alpha
          })
        let rectSize: CGFloat = pointSize.height * 2 + 6
        ColorSampler(color: bind) { value in
          hue = value.hue
          saturation = value.saturation
          brightness = value.brightness
          alpha = value.alpha
        }
        .rectSize(viewModel.showsAlpha == true ? rectSize : pointSize.height)
      }
      let uiColor = UIColor(
        hue: hue,
        saturation: saturation,
        brightness: brightness,
        alpha: alpha
      )
      Swatch(uiColor: uiColor) { value in
        hue = value.hue
        saturation = value.saturation
        brightness = value.brightness
        alpha = value.alpha
      }
    }
    .padding(12)
  }
  public func showsAlpha(_ value: Bool) -> some View {
    viewModel.showsAlpha = value
    return self
  }
  public func showsAlpha(_ value: Binding<Bool>) -> some View {
    viewModel.showsAlpha = value.wrappedValue
    return self
  }
}

public struct Saturation: View {
  @Environment(\.pointSize) private var pointSize
  @Environment(\.cornerSize) private var cornerSize
  @Binding var saturation: CGFloat
  @Binding var brightness: CGFloat
  var hue: CGFloat
  public init(
    saturation: Binding<CGFloat>,
    brightness: Binding<CGFloat>,
    hue: CGFloat = 0
  ) {
    self._saturation = saturation
    self._brightness = brightness
    self.hue = hue
  }
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        RoundedRectangle(cornerRadius: cornerSize, style: .continuous)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [
                Color(hue: hue, saturation: 0, brightness: 1),
                Color(hue: hue, saturation: 1, brightness: 1),
              ]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .overlay(
            RoundedRectangle(cornerRadius: cornerSize, style: .continuous)
              .stroke(Color.secondary.opacity(0.26), lineWidth: 2)
          )
          .overlay(
            LinearGradient(
              gradient: Gradient(stops: [
                .init(color: Color.white, location: 0.0),
                .init(color: Color(white: 0.6, opacity: 0.5), location: 0.4),
                .init(color: Color(white: 0.05), location: 1.0),
              ]),
              startPoint: .top,
              endPoint: .bottom
            )
            .blendMode(.multiply)
            .mask(RoundedRectangle(cornerRadius: cornerSize, style: .continuous))
          )
        Circle()
          .fill(Color(hue: hue, saturation: saturation, brightness: brightness))
          .frame(width: pointSize.width, height: pointSize.height)
          .overlay(Circle().stroke(Color.secondary.opacity(0.37), lineWidth: 4))
          .overlay(Circle().stroke(Color.white, lineWidth: 2))
          .position(
            x: saturation * geometry.size.width,
            y: (1 - brightness) * geometry.size.height
          )
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            let x = value.location.x
            let y = value.location.y
            let width = geometry.size.width
            let height = geometry.size.height

            saturation = min(max(x / width, 0), 1)
            brightness = 1 - min(max(y / height, 0), 1)
          }
      )
    }
  }
}

public struct AlphaSlider: View {
  @Environment(\.pointSize) private var pointSize
  @Environment(\.cornerSize) private var cornerSize
  @Binding var alpha: CGFloat
  var hue: CGFloat
  var saturation: CGFloat
  var brightness: CGFloat
  public init(
    alpha: Binding<CGFloat>,
    hue: CGFloat = 0,
    saturation: CGFloat = 1,
    brightness: CGFloat = 1,
  ) {
    self._alpha = alpha
    self.hue = hue
    self.saturation = saturation
    self.brightness = brightness
  }
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        RoundedRectangle(cornerRadius: cornerSize)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [
                Color(hue: hue, saturation: saturation, brightness: brightness, opacity: 0.0),
                Color(hue: hue, saturation: saturation, brightness: brightness, opacity: 1.0),
              ]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .overlay(
            RoundedRectangle(cornerRadius: cornerSize).stroke(
              Color.secondary.opacity(0.37), lineWidth: 2)
          )
          .background(
            CheckerboardBackground(squareSize: 5)
              .clipShape(RoundedRectangle(cornerRadius: cornerSize))
              .opacity(0.45)
          )
          .clipShape(RoundedRectangle(cornerRadius: cornerSize))

        Circle()
          .fill(Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha))
          .background(
            CheckerboardBackground(squareSize: 5)
              .clipShape(RoundedRectangle(cornerRadius: cornerSize))
          )
          .frame(width: pointSize.width, height: pointSize.height)
          .overlay(Circle().stroke(Color.secondary.opacity(0.37), lineWidth: 4))
          .overlay(Circle().stroke(Color.white, lineWidth: 2))
          .position(
            x: min(
              max(alpha * geometry.size.width, pointSize.width / 2),
              geometry.size.width - pointSize.width / 2),
            y: geometry.size.height / 2
          )
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            let x = value.location.x
            let width = geometry.size.width
            alpha = min(max(x / width, 0), 1)
          }
      )
    }
    .frame(height: pointSize.height)
  }
}

struct CheckerboardBackground: View {
  var squareSize: CGFloat = 3
  var body: some View {
    Canvas { context, size in
      let rows = Int(size.height / squareSize) + 1
      let cols = Int(size.width / squareSize) + 1
      for row in 0..<rows {
        for col in 0..<cols {
          let x = CGFloat(col) * squareSize
          let y = CGFloat(row) * squareSize
          let isEven = (row + col) % 2 == 0
          let color = isEven ? Color(white: 0.9) : Color(white: 0.7)
          context.fill(
            Path(CGRect(x: x, y: y, width: squareSize, height: squareSize)),
            with: .color(color)
          )
        }
      }
    }
  }
}

public struct HueSlider: View {
  @Environment(\.pointSize) private var pointSize
  @Environment(\.cornerSize) private var cornerRadius
  @Binding var hue: CGFloat
  public init(hue: Binding<CGFloat>) {
    self._hue = hue
  }
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [
                Color(hue: 0.0, saturation: 1, brightness: 1),
                Color(hue: 0.167, saturation: 1, brightness: 1),
                Color(hue: 0.333, saturation: 1, brightness: 1),
                Color(hue: 0.5, saturation: 1, brightness: 1),
                Color(hue: 0.667, saturation: 1, brightness: 1),
                Color(hue: 0.833, saturation: 1, brightness: 1),
                Color(hue: 1.0, saturation: 1, brightness: 1),
              ]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .overlay(
            RoundedRectangle(cornerRadius: cornerRadius).stroke(
              Color.secondary.opacity(0.37), lineWidth: 2)
          )
          .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

        Circle()
          .fill(Color(hue: hue, saturation: 1, brightness: 1))
          .frame(width: pointSize.width, height: pointSize.height)
          .overlay(Circle().stroke(Color.secondary.opacity(0.37), lineWidth: 4))
          .overlay(Circle().stroke(Color.white, lineWidth: 2))
          .position(
            x: min(
              max(hue * geometry.size.width, pointSize.width / 2),
              geometry.size.width - pointSize.width / 2),
            y: geometry.size.height / 2
          )
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            let x = value.location.x
            let width = geometry.size.width
            hue = min(max(x / width, 0), 1)
          }
      )
    }
    .frame(height: pointSize.height)
  }
}

extension UIColor {
  var hue: CGFloat {
    var value: CGFloat = 0
    self.getHue(&value, saturation: nil, brightness: nil, alpha: nil)
    return value
  }
  var saturation: CGFloat {
    var value: CGFloat = 0
    self.getHue(nil, saturation: &value, brightness: nil, alpha: nil)
    return value
  }
  var brightness: CGFloat {
    var value: CGFloat = 0
    self.getHue(nil, saturation: nil, brightness: &value, alpha: nil)
    return value
  }
}

extension Color {
  var toUIColor: UIColor? {
    guard let cgColor = self.cgColor else { return nil }
    return UIColor(cgColor: cgColor)
  }
  var alpha: CGFloat {
    let uiColor = self.toUIColor
    var value: CGFloat = 1
    uiColor?.getHue(nil, saturation: nil, brightness: nil, alpha: &value)
    return value
  }
  var hue: CGFloat {
    let uiColor = self.toUIColor
    var value: CGFloat = 0
    uiColor?.getHue(&value, saturation: nil, brightness: nil, alpha: nil)
    return value
  }
  var saturation: CGFloat {
    let uiColor = self.toUIColor
    var value: CGFloat = 0
    uiColor?.getHue(nil, saturation: &value, brightness: nil, alpha: nil)
    return value
  }
  var brightness: CGFloat {
    let uiColor = self.toUIColor
    var value: CGFloat = 0
    uiColor?.getHue(nil, saturation: nil, brightness: &value, alpha: nil)
    return value
  }
  func contrastingColor(
    lightColor: UIColor = .white, darkColor: UIColor = .black, threshold: CGFloat = 0.5
  ) -> Color? {
    let uiColor = self.toUIColor
    guard
      let uiColor = uiColor?.contrastingColor(
        lightColor: lightColor, darkColor: darkColor, threshold: threshold)
    else { return nil }
    return Color(uiColor: uiColor)
  }
}

extension UIColor {
  var alpha: CGFloat {
    var value: CGFloat = 1
    self.getHue(nil, saturation: nil, brightness: nil, alpha: &value)
    return value
  }
  func isEqual(to other: UIColor?) -> Bool {
    self == other
  }

  var luminance: CGFloat? {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    self.getRed(&r, green: &g, blue: &b, alpha: nil)

    return 0.2126 * r + 0.7152 * g + 0.0722 * b
  }


  func contrastingColor(
    lightColor: UIColor = .white, darkColor: UIColor = .black, threshold: CGFloat = 0.5
  ) -> UIColor? {
    guard let luminance = self.luminance else { return nil }
    return luminance > threshold ? darkColor : lightColor
  }
}

@available(macCatalyst 17.0, *)
public struct ColorSelection: View {
  @State var hue: CGFloat = 1.0
  @State var saturation: CGFloat = 1.0
  @State var brightness: CGFloat = 1.0
  @State var alpha: CGFloat = 1.0

  @Binding var color: Color
  public init(color: Binding<Color>) {
    _color = color
  }
  public var body: some View {
    VStack {
      Sketch(hue: $hue, saturation: $saturation, brightness: $brightness, alpha: $alpha)
        .padding()
      VStack {

        LabeledContent("Hue:") {
          Text("\(hue, specifier: "%.2f")")
        }
        LabeledContent("Saturation") {
          Text("\(saturation, specifier: "%.2f")")
        }
        LabeledContent("Brightness:") {
          Text("\(brightness, specifier: "%.2f")")
        }
        LabeledContent("Alpha:") {
          Text("\(alpha, specifier: "%.2f")")
        }
      }
      .padding()
    }
    .font(.caption2)
    .monospaced()
      .onChange(of: color, initial: true) { _, color in
        guard color != self.color else { return }
        @State var hue: CGFloat = 1.0
        @State var saturation: CGFloat = 1.0
        @State var brightness: CGFloat = 1.0
        @State var alpha: CGFloat = 1.0
        PlatformColor(color).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if hue != self.hue {
          self.hue = hue
        }
        if saturation != self.saturation {
          self.saturation = saturation
        }
        if brightness != self.brightness {
          self.brightness = brightness
        }
        if alpha != self.alpha {
          self.alpha = alpha
        }
      }
      .onChange(of: AnyHashable(of: hue, saturation, brightness, alpha)) {
        self.color = Color(PlatformColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
      }
  }
  #if canImport(UIKit)
  typealias PlatformColor = UIColor
  #elseif canImport(AppKit)
  typealias PlatformColor = NSColor
  #else
  typealias PlatformColor = Never
  #endif

}


@available(macCatalyst 17.0, *)
public struct ColorPaletteView: View {
  public init(color: Binding<Color>) {
    _color = color
  }
  

  @Binding var color: Color
  @State var present: Bool = false
  public var body: some View {
    GeometryReader { proxy in
      Button {
        present.toggle()
      } label: {
        RoundedRectangle(cornerRadius: max(proxy.size.width, proxy.size.height) * 0.2, style: .continuous)
          .strokeBorder(.primary, lineWidth: 3, antialiased: true)
          .fill(.white.opacity(0.01))
          .fill(color)
          .betterShadow()
      }
      .buttonStyle(.plain)
      .frame(minWidth: 30, minHeight: 30)
    }
    .popover(isPresented: $present) {
      if #available(macCatalyst 17.0, *) {
        ColorSelection(color: $color)
          .frame(minWidth: 200, minHeight: 400)
      } else {
        // Fallback on earlier versions
      }
    }
  }

}

extension AnyHashable {
  public init<each T: Hashable>(of many: repeat each T) {
    var group: [AnyHashable] = []
    for a in repeat each many {
      group.append(AnyHashable(a))
    }
    self = .init(group)
  }
}
//
//
extension View {
/// Applies a soft shadow effect based on Material Design elevation principles.
///
/// This modifier automatically calculates appropriate shadow properties based on the elevation value,
/// following Material Design guidelines for creating consistent shadow hierarchies.
///
/// ```swift
/// VStack {
///     Text("Card 1").betterShadow(elevation: 2)
///     Text("Card 2").betterShadow(elevation: 8)
/// }
/// ```
///
/// - Parameters:
///   - color: The shadow color. Defaults to black.
///   - elevation: The height of the surface in points. Higher values create larger shadows. Defaults to 4.
///   - opacity: The shadow opacity, ranging from 0 to 1. Defaults to 0.25.
///   - x: Additional horizontal offset. Defaults to 0.
///   - y: Additional vertical offset. Defaults to 0.
/// - Returns: A view with elevation-based shadow applied.
public func betterShadow(
  color: Color = .black,
  elevation: CGFloat = 4,
  opacity: CGFloat = 0.25,
  x: CGFloat = 0,
  y: CGFloat = 0
) -> some View {
  modifier(
    SoftShadow(
      color: color,
      radius: elevation,
      opacity: opacity,
      xOffset: x == 0 ? 0 : x + (elevation / 2),
      yOffset: y == 0 ? 0 : y + (elevation / 2)
    )
  )
}

/// Applies a gradient shadow effect with customizable properties.
///
/// This modifier creates a shadow effect using any SwiftUI gradient type, allowing for
/// creative shadow effects that can enhance your UI's visual hierarchy.
///
/// ```swift
/// Text("Gradient Shadow")
///     .gradientShadow(
///         gradient: LinearGradient(
///             colors: [.blue, .purple],
///             startPoint: .topLeading,
///             endPoint: .bottomTrailing
///         ),
///         radius: 10,
///         opacity: 0.3
///     )
/// ```
///
/// - Parameters:
///   - gradient: The gradient to use for the shadow.
///   - opacity: The opacity of the shadow (0.0-1.0).
///   - radius: The blur radius of the shadow.
///   - x: Horizontal offset of the shadow.
///   - y: Vertical offset of the shadow.
/// - Returns: A view with the gradient shadow effect applied.
public func proGradientShadow<G: GradientStyle>(
  gradient: G = LinearGradient(
    colors: [.red, .blue],
    startPoint: .top,
    endPoint: .bottom
  ),
  opacity: CGFloat = 0.25,
  radius: CGFloat = 8,
  x: CGFloat = 0,
  y: CGFloat = 0
) -> some View {
  modifier(
    GradientShadow(
      gradient: gradient,
      radius: radius,
      opacity: opacity,
      xOffset: x,
      yOffset: y
    )
  )
}
}
//
//  Gradient+Ext.swift
//  ShadowKit
//
//  Created by Siddhant Mehta on 2025/02/18.
//

/// Defines the requirements for gradient styles that can be used with shadow effects.
///
/// This protocol is adopted by SwiftUI's built-in gradient types:
/// - `LinearGradient`
/// - `AngularGradient`
/// - `RadialGradient`
/// - `EllipticalGradient`
public protocol GradientStyle: ShapeStyle {}

extension LinearGradient: GradientStyle {}
extension AngularGradient: GradientStyle {}
extension RadialGradient: GradientStyle {}
extension EllipticalGradient: GradientStyle {}
// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A view modifier that creates realistic shadows by combining multiple layers with varying intensities.
///
/// `SoftShadow` improves upon SwiftUI's native shadow by using a multi-layered approach that better
/// simulates real-world lighting conditions. Each shadow layer has different properties that combine
/// to create a more natural-looking shadow effect.
///
/// Example usage:
/// ```swift
/// Text("Hello")
///     .padding()
///     .background(Color.white)
///     .softShadow(
///         color: .black,
///         radius: 8,
///         opacity: 0.25,
///         x: 0,
///         y: 4
///     )
/// ```
public struct SoftShadow: ViewModifier {
private let color: Color
private let radius: CGFloat
private let opacity: Double
private let xOffset: CGFloat
private let yOffset: CGFloat

/// Creates a new soft shadow modifier.
/// - Parameters:
///   - color: The color of the shadow.
///   - radius: The blur radius of the shadow.
///   - opacity: The opacity of the shadow (0.0-1.0).
///   - xOffset: Horizontal offset of the shadow.
///   - yOffset: Vertical offset of the shadow.
public init(
  color: Color = .black,
  radius: CGFloat = 8,
  opacity: Double = 0.25,
  xOffset: CGFloat = 0,
  yOffset: CGFloat = 0
) {
  self.color = color
  self.radius = radius
  self.opacity = opacity
  self.xOffset = xOffset
  self.yOffset = yOffset
}

/// Calculates the dynamic radius based on offset magnitude.
/// - Parameter baseRadius: The base radius to adjust.
/// - Returns: An adjusted radius that takes into account the shadow's offset.
private func dynamicRadius(_ baseRadius: CGFloat) -> CGFloat {
  let offsetMagnitude = sqrt(pow(xOffset, 2) + pow(yOffset, 2))
  let radiusMultiplier = max(1.0, 1.0 + (offsetMagnitude / 32) * 0.5)
  return baseRadius * radiusMultiplier
}

public func body(content: Content) -> some View {
  content
    // Layer 1: Tight shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        color: color,
        radius: dynamicRadius(radius / 16),
        opacity: opacity,
        xOffset: xOffset / 16,
        yOffset: yOffset / 16
      )
    )
    // Layer 2: Medium shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        color: color,
        radius: dynamicRadius(radius / 8),
        opacity: opacity,
        xOffset: xOffset / 8,
        yOffset: yOffset / 8
      )
    )
    // Layer 3: Wide shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        color: color,
        radius: dynamicRadius(radius / 4),
        opacity: opacity,
        xOffset: xOffset / 4,
        yOffset: yOffset / 4
      )
    )
    // Layer 4: Broader shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        color: color,
        radius: dynamicRadius(radius / 2),
        opacity: opacity,
        xOffset: xOffset / 2,
        yOffset: yOffset / 2
      )
    )
    // Layer 5: Broadest shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        color: color,
        radius: dynamicRadius(radius),
        opacity: opacity,
        xOffset: xOffset,
        yOffset: yOffset
      ))
}

/// A single layer of the soft shadow effect.
private struct InnerShadowLayer: ViewModifier {
  let content: Any
  let color: Color
  let radius: CGFloat
  let opacity: Double
  let xOffset: CGFloat
  let yOffset: CGFloat

  private let additionalBlur: CGFloat = 2

  /// Calculates the final y-offset including dynamic adjustments.
  private var calculatedYOffset: CGFloat {
    yOffset + ((yOffset >= 0 ? 1 : -1) * radius) + ShadowConstants.additionalBlur
  }

  func body(content: Content) -> some View {
    content
      .shadow(
        color: color.opacity(opacity),
        radius: radius + ShadowConstants.additionalBlur,
        x: xOffset,
        y: calculatedYOffset
      )
  }
}
}
//
//  GradientShadow.swift
//  ShadowKit
//
//  Created by Siddhant Mehta on 2025-02-17.
//

///  A view modifier that creates a multi-layered gradient shadow effect.
///
///  `GradientShadow` uses multiple layers of gradient-based shadows to create a rich,
///  depth-enhancing effect that can use any SwiftUI gradient type.
///
///  Example usage:
///  ```swift
///  Text("Hello")
///      .padding()
///      .background(Color.white)
///      .gradientShadow(
///          gradient: LinearGradient(colors: [.blue, .purple],
///                                 startPoint: .topLeading,
///                                 endPoint: .bottomTrailing),
///          radius: 10,
///          opacity: 0.3
///      )
///  ```
public struct GradientShadow<G: GradientStyle>: ViewModifier {
private let gradient: G
private let radius: CGFloat
private let opacity: Double
private let xOffset: CGFloat
private let yOffset: CGFloat

/// Creates a new gradient shadow modifier.
/// - Parameters:
///   - gradient: The gradient to use for the shadow effect.
///   - radius: The blur radius of the shadow.
///   - opacity: The opacity of the shadow (0.0-1.0).
///   - xOffset: Horizontal offset of the shadow.
///   - yOffset: Vertical offset of the shadow.
public init(
  gradient: G,
  radius: CGFloat,
  opacity: Double,
  xOffset: CGFloat,
  yOffset: CGFloat
) {
  self.gradient = gradient
  self.radius = radius
  self.opacity = opacity
  self.xOffset = xOffset
  self.yOffset = yOffset
}

/// Calculates a dynamic radius that adjusts based on the shadow's offset.
/// - Parameter baseRadius: The base radius to adjust.
/// - Returns: An adjusted radius that takes into account the shadow's offset.
private func dynamicRadius(_ baseRadius: CGFloat) -> CGFloat {
  let offsetMagnitude = sqrt(pow(xOffset, 2) + pow(yOffset, 2))
  let radiusMultiplier = max(1.0, 1.0 + (offsetMagnitude / 32) * 0.5)
  return baseRadius * radiusMultiplier
}

public func body(content: Content) -> some View {
  content
    // Layer 1: Tight shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        gradient: gradient,
        radius: dynamicRadius(radius / 16),
        opacity: opacity,
        xOffset: xOffset / 16,
        yOffset: yOffset / 16
      )
    )
    // Layer 2: Medium shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        gradient: gradient,
        radius: dynamicRadius(radius / 8),
        opacity: opacity,
        xOffset: xOffset / 8,
        yOffset: yOffset / 8
      )
    )
    // Layer 3: Wide shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        gradient: gradient,
        radius: dynamicRadius(radius / 4),
        opacity: opacity,
        xOffset: xOffset / 4,
        yOffset: yOffset / 4
      )
    )
    // Layer 4: Broader shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        gradient: gradient,
        radius: dynamicRadius(radius / 2),
        opacity: opacity,
        xOffset: xOffset / 2,
        yOffset: yOffset / 2
      )
    )
    // Layer 5: Broadest shadow
    .modifier(
      InnerShadowLayer(
        content: content,
        gradient: gradient,
        radius: dynamicRadius(radius),
        opacity: opacity,
        xOffset: xOffset,
        yOffset: yOffset
      ))
}

/// A single layer of the gradient shadow effect.
private struct InnerShadowLayer: ViewModifier {
  let content: Any
  let gradient: G
  let radius: CGFloat
  let opacity: Double
  let xOffset: CGFloat
  let yOffset: CGFloat

  /// Calculates the final y-offset including dynamic adjustments.
  private var calculatedYOffset: CGFloat {
    yOffset + ((yOffset >= 0 ? 1 : -1) * radius) + ShadowConstants.additionalBlur
  }

  func body(content: Content) -> some View {
    content
      .background {
        Rectangle()
          .fill(gradient)
          .opacity(opacity)
          .mask {
            content
          }
          .offset(
            x: xOffset,
            y: calculatedYOffset
          )
          .blur(radius: radius + ShadowConstants.additionalBlur)
      }
  }
}
}
//
//  Constants.swift
//  ShadowKit
//
//  Created by Siddhant Mehta on 2025/02/18.
//

/// Internal constants used by the shadow system
enum ShadowConstants {
/// Additional blur applied to shadows to enhance their natural appearance
static let additionalBlur: CGFloat = 2
}
