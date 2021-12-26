//
//  ContentView.swift
//  CSV Import
//
//  Created by Matthias Deuschl on 23.12.21.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("Last index used") var index = 0
    var rawFile: String {
        if (samples.startIndex..<samples.endIndex).contains(index) {
            return samples[index]
        } else {
            return "'index' (\(index)),out,of,BOUNDS (\(samples.startIndex)..<\(samples.endIndex))!"
        }
    }
    var file: CSVFile {
        CSVFile(file: rawFile, fieldSeparator: ",")
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Raw file")
                .font(.headline)
            Text(rawFile)
                .border(.green, width: 1.0)
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Parsed fields")
                        .font(.headline)
                    ForEach(file.lines) { line in
                        Text("___LINE___ (\(line.fields.count))")
                        HStack(alignment: .firstTextBaseline) {
                        ForEach(line.fields, id:\.self) { field in
                                Text(field.replacingOccurrences(of: "\"\"", with: "\""))
                                    .padding(1.0)
                                    .border(Color.red, width: 1.0)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            Stepper("Current index: \(index)", value: $index)
                .padding(.vertical)
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
