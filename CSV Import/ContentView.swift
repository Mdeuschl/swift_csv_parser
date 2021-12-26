//
//  ContentView.swift
//  CSV Import
//
//  Created by Matthias Deuschl on 23.12.21.
//

import SwiftUI

let samples = [
"Regular,csv,file\ra,b,c\r\n1,2,3",
"Emoji,special,characters\r🥰,½,c\r\n1,&quot;,3\n4,5,ʤ",
"Different New Lines:\r(r)\n(n)\r\n(rn)",
"Empty,line,after,(r)\r",
"Empty,line,after,(n)\n",
"Empty,line,after,(rn)\r\n",
"Two,empty,lines,after,(rn)\r\n\r\n",
"""
Quoted,second,field
ha ha ha,\"ha \"\"ha\"\" ha\","ha,ha,ha"
ha,"ha",ha
""",
"""

\"Empty line above\"
""",
"""
first,last,address,city,zip
John,Doe,120 any st.,"Anytown, WW",08123
""", //4 extra empty field aufter Anytown…
"""
a,b
1,"ha
""ha""
ha"
3,4
""", //5 okay.
"""
a,b,c
1,"",""
2,3,4
""", //6 no new line after empty fields
"""
key,val
1,"{""type"": ""Point"", ""coordinates"": [102.0, 0.5]}"
2,"{""type"": ""Point"", ""coordinates"": [99.8, -1.5]}"
""", //7 okay
"""
1,2,3,4,5
"1",two,"III","",""
,,,….,.….
""", //8 one empty field too many in second record.
"""
"Format Error 1","Unterminated Quote
""", //9 extraneuos empty field
"""
Format Error,Quote inside "Field"
#2 "🤯", "leading space and unterminated Quote
""" //10
]


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
