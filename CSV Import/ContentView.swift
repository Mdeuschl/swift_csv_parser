//
//  ContentView.swift
//  CSV Import
//
//  Created by Matthias Deuschl on 23.12.21.
//

import SwiftUI

struct ContentView: View {
    let file = CSVFile(file: sampleData, fieldSeparator: ",")
    var body: some View {
        ScrollView {
            ForEach(file.lines) { line in
                Text("___LINE___")
                ForEach(line.fields, id:\.self) { field in
                    HStack(alignment: .firstTextBaseline) {
                        Text("Field:")
                        Text("'" + field + "'")
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
