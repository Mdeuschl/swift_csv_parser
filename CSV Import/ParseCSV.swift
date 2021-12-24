//
//  ParseCSV.swift
//  AufdieWaage
//
//  Created by Matthias Deuschl on 23.12.21.
//

import Foundation

let sampleData = "Date;\"Weight [lb]\"\r\n\"11/12/2021, 10:36:00\";\"163.3\"\r\n\"12/12/2021, 10:24:00\";\"162.8\"\r\n\"13/12/2021, 11:03:57\";\"162.7\"\r\n\"18/12/2021, 08:43:00\";\"162.9\"\r\n\"21/12/2021, 10:23:54\";\"162.2\"\r\n" + "\"Text with \"\"DoubleQuotes\"\" in it;72,7\r\n" + ";72,2\r\n"

struct LineOfFileds: Hashable, Identifiable {
    var fields: Array<Substring>
    let id = UUID()
}

struct CSVFile: Identifiable {
    let id = UUID()
    let file: String
    var lines: Array<LineOfFileds>
    var fieldSeparator: Character // Usually , or ; -- to separate fields from each other
    init(file: String, fieldSeparator: Character) {
        self.file = file
        self.fieldSeparator = fieldSeparator
        self.lines = []
        print(self.parse(maxLines: 5))
    }
    mutating func parse(maxLines: Int? = 5) -> (lines: Int, fields: Int) {
        var isInField = false
        var fieldIsQuoted = false
        var i: String.Index = file.startIndex
        var rangeStart: String.Index  = file.startIndex
        var rangeEnd: String.Index  = file.startIndex
        var linesCount = 0
        var fieldsCount = 0
        var fieldIsDone = false
        var lineIsDone = false
        var fieldsInLine: Array<Substring> = []
        while i < file.endIndex && (maxLines == nil || linesCount <= maxLines!) && file[rangeStart..<i].count < 100 {
            let thisChar = file[i]
            let iNext = file.index(after: i)
            switch (isInField: isInField, fieldIsQuoted: fieldIsQuoted, char: thisChar) {
            case (isInField: false, fieldIsQuoted: false, "\""):
                fieldIsQuoted = true
            case (isInField: true, fieldIsQuoted: true, "\""):
                if iNext < file.endIndex && file[iNext] == "\"" {
                    //we found a doubled " which should be treated like a single "
                    i = iNext
                } else {
                    //we're at the end of the quoted field.
                    isInField = false
                    rangeEnd = i
                    fieldIsDone = true
                }
            case (isInField: false, fieldIsQuoted: true, "\""):
                if iNext < file.endIndex {
                    if file[iNext] == fieldSeparator {
                        //that's a quoted empty field.
                        rangeStart = i
                        rangeEnd = i
                        fieldIsDone = true
                        i = iNext
                    } // else just a regular text inside the stupid file.
                } else { //file is ending after this ???

                }
            case (isInField: false, fieldIsQuoted: true, _):
                rangeStart = i
                isInField = true

            case (isInField: true, fieldIsQuoted: true, _):
                //just proceed to next. We're looking for " only.
                ()
            case (isInField: true, fieldIsQuoted: false, fieldSeparator):
                rangeEnd = i
                isInField = false
                fieldIsDone = true
            case (isInField: true, fieldIsQuoted: false, "\r"):
                fallthrough
            case (isInField: true, fieldIsQuoted: false, "\n"):
                fallthrough
            case (isInField: true, fieldIsQuoted: false, "\r\n"):
                rangeEnd = i
                isInField = false
                fieldIsDone = true
                lineIsDone = true
            case (isInField: false, fieldIsQuoted: true, "\r"):
                fallthrough
            case (isInField: false, fieldIsQuoted: true, "\n"):
                fallthrough
            case (isInField: false, fieldIsQuoted: true, "\r\n"):
                print("hello, breakpoint!")
                lineIsDone = true
            case (isInField: false, fieldIsQuoted: _, _):
                print("nope not here.")
                rangeStart = i
                isInField = true
            default:
                print("Unhandled case: inField: \(isInField), quoted: \(fieldIsQuoted), char: \(thisChar)")
            }
            if !fieldIsDone {
                if iNext == file.endIndex {
                    fieldIsDone = true
                    lineIsDone = true
                }
            }
            if fieldIsDone {
                fieldIsDone = false
                let subString = file[rangeStart..<rangeEnd]
                fieldsInLine.append(subString)
                print("Field done: ", subString)
                isInField = false
                fieldIsQuoted = false
                fieldsCount += 1
            }
            if lineIsDone {
                lines.append(LineOfFileds(fields: fieldsInLine))
                fieldsInLine = []
                linesCount += 1
            }
            i = file.index(after: i)
        }
        return (linesCount, fieldsCount)
    }
}


