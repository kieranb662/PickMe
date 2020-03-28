# PickMe

[Example Gif](PickMe.gif)!

A SwiftUI Library for cascading styling of selectable view content. Use one of 3 `.selectable`  view modifiers depending upon the type of selection you are using. 


The three types of selections are - 

1. Single Selection(`Hashable`): One object must be currently selected
2. Optional Single Selection(`Hashable?`): At most one object may be selected
3. Multi Selection(`Set<Hashable>`): Zero or many  objects may be selected concurrently 


## Copy Paste Example 

``` swift
import SwiftUI
import PickMe

public struct CoolSelectableStyle: SelectableStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.view
            .foregroundColor(configuration.isSelected ? Color.white : Color.black)
            .background(configuration.isSelected ? Color.blue: Color.clear)
            .border(configuration.isSelected ? Color.purple : Color.clear)
            .animation(.easeIn)
            .rotationEffect(configuration.isSelected ? Angle(degrees: -359) : Angle(degrees: 0))
            .animation(configuration.isSelected ? Animation.linear(duration: 3).repeatForever(autoreverses: false) : Animation.default)

    }
}

struct PulseEffect<S: Shape>: ViewModifier {
    
    var shape: S
    @State var isOn: Bool = false
    
    func body(content: Content) -> some View {
        content.padding().background(ZStack {
            
            shape
                .stroke(Color.yellow, lineWidth: 1)
                .scaleEffect(self.isOn ? 2 : 1)
                .opacity(self.isOn ? 0 : 1)
                .animation(Animation.easeIn(duration: 1).repeatForever(autoreverses: false))
             shape.stroke(Color.blue)
        })
            .onAppear {
                self.isOn = true
        }
    }
}


extension View {
    func pulse<S: Shape>(_ shape: S) -> some View  {
        self.modifier(PulseEffect(shape: shape))
    }
}

public struct PulseSelectableStyle: SelectableStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        Group {
            if configuration.isSelected {
                configuration.view
                .pulse(Circle())
            }else {
                configuration.view
            }
        }
    }
}

struct SelectableView: View {
//    @State var selection: Int = 1
//    @State var selection: Int? = nil
    @State var selection: Set<Int> = []
    
    
    var body: some View {
        HStack {
            Text("Select Me").padding()
                .selectable(selection: $selection, id: 1)
            
            Text("Or Me").padding()
                .selectable(selection: $selection, id: 4)
                .selectableStyle(PulseSelectableStyle())
            Ellipse().fill(Color.purple)
                .frame(width: 100, height: 40)
            .padding()
                .selectable(selection: $selection, id: 6)
            .selectableStyle(CoolSelectableStyle())
        }
    }
}

struct SelectableView_Previews: PreviewProvider {
    static var previews: some View {
        SelectableView()
    }
}

```


## Example Explained 



In order to make full use of styling selectable content, one must create a `SelectableStyle` conforming struct. 


``` swift
public struct CoolSelectableStyle: SelectableStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.view
            .foregroundColor(configuration.isSelected ? Color.white : Color.black)
            .background(configuration.isSelected ? Color.blue: Color.clear)
            .border(configuration.isSelected ? Color.purple : Color.clear)
            .animation(.easeIn)
            .rotationEffect(configuration.isSelected ? Angle(degrees: -359) : Angle(degrees: 0))
            .animation(configuration.isSelected ? Animation.linear(duration: 3).repeatForever(autoreverses: false) : Animation.default)

    }
}
```

The custom style struct contains a single method with a parameter `SelectableConfiguration` 

``` swift
public struct SelectableConfiguration {
    public let view: AnyView
    public let isSelected: Bool
}
```
`SelectableConfiguration`  gives you access to the underlying view that is being selected as well as a value describing the selection state of the view. 


