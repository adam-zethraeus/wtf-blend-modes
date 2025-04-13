import SwiftUI
enum Item: String, Identifiable & Hashable & CaseIterable {
  var id: Self { self }
  case square
  case roundedSquare
  case circle

  static var allCases: [Item] {
    [.square, .roundedSquare, .circle]
  }
}

struct BGPicker: View {



  @Binding var item: Item

  var body: some View {
    Picker(selection: $item) {
      ForEach(Item.allCases) { item in
        Text(item.rawValue)
      }
    } label: {
      Text(item.rawValue)
    }

  }
}
