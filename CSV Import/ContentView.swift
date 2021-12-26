//
//  ContentView.swift
//  CSV Import
//
//  Created by Matthias Deuschl on 23.12.21.
//

import SwiftUI

let samples = [
"Regular,csv,file\rwith,three,records\r\nand,three fields,each.",
"Emoji,and special,characters\r🥰,½,c\r\n1,&quot;,3\n4,5,ʤ",
"Different New Lines:\r(r)\n(n)\r\n(rn)",
"Empty,line,after,(r)\r",
"Empty,line,after,(n)\n",
"Empty,line,after,(rn)\r\n",
"Two,empty,lines,after,(rn)\r\n\r\n",
"""

"Empty","line","above"
""",
"""
Quoted,second,field
First,"2nd",third
First,"2 with ""Double"" quote.","3."
"Quoted","Fields","with ""double"" Quotes"
"Quoted
Fields","with
new
lines, and comma","in it"
""",
"Empty file follows",
"""
""",
"""
first,last,address,city,zip
John,Doe,120 Any Street,"Anytown, WW",08123
""",
"""
a,b,c
1,"",""
2,3,4
""",
"""
key,val
1,"{""type"": ""Point"", ""coordinates"": [102.0, 0.5]}"
2,"{""type"": ""Point"", ""coordinates"": [99.8, -1.5]}"
""",
"""
1,2,3,4,5
"1",two,"III","",""
,,,….,.….
""", //8 one empty field too many in second record.
"""
Format Errors:,"Un- or improperly terminated Quotes"
"1. Quote@start,second field has closing quote"
2. No Quote @ start,"second field only has opening quote
Third line w/ trailing quote to correct error"
"4th line starts with open ended quote before EOF.
""",
"""
Format Errors:,"More quote errors",
1st "line",with "single" double quotes,inside unquoted field
"2nd line with" Text behind closing quote,and two,other unquoted fields
\"\"3rd starting with double quote in unquoted field,"plus regular quoted field",
"\"\"4th: Triple Quote @start,closed with another triple.\"\"\"
""",
"""
Format Errors:,"Quotes and EOF"
#1,"Open ended, quoted field.
""",
"""
Format Errors:,"Quotes and EOF"
#2,Open ended,"single quoted field.
""",
"""
Format Errors:,"Quotes and EOF"
#3,Open ended double quote,\"\"with double quote \"\" in it.
""",
"""
Format Errors:,"Quotes and EOF"
#4,Open ended,\"\"\"triple quoted field.
""",
"""
Format Errors:,"Quotes and EOF"
#5,Single Quotes in,unquoted" field.
""",
"""
Format Errors:,"Quotes and EOF"
#6,Double Quotes in,unquoted\"\" field.
""",
"""
Format Errors:,"Quotes and EOF"
#7,Triple Quotes in,unquoted\"\"\" field.
""",
"""
Format Errors:,"Quotes and EOF"
#8,Quadruple Quotes in,unquoted\"\"\"\" field.
""",
"""
Format Errors:,"Quotes and EOF"
#9,Single quote,right beforeEOF"
""",
"""
Format Errors:,"Quotes and EOF"
#10,Double quote,right beforeEOF\"\"
""",
"""
Format Errors:,"Quotes and EOF"
#11,Triple quote,right beforeEOF\"\"\"
""",
"""
Format Errors:,"Quotes and EOF"
#12,Quadruple quote,right beforeEOF\"\"\"\"
"""
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
    var csvFile: CSVFile {
        CSVFile(file: rawFile, fieldSeparator: ",", tryMaxLines: 5)
    }
    var body: some View {
        let file = csvFile
        VStack(alignment: .leading) {
            Text("Raw file")
                .font(.headline)
            Text(rawFile)
                .border(file.errorFree ? .green : .red, width: 1.0)
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Parsed fields")
                        .font(.headline)
                    ForEach(file.lines) { line in
                        Text("_ _ _ LINE _ _ _ (\(line.fields.count))")
                        HStack(alignment: .firstTextBaseline) {
                        ForEach(line.fields, id:\.self) { field in
                                Text(field.replacingOccurrences(of: "\"\"", with: "\""))
                                    .padding(1.0)
                                    .border(Color.primary, width: 1.0)
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
