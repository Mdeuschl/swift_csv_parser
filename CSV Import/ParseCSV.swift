//
//  ParseCSV.swift
//  AufdieWaage
//
//  Created by Matthias Deuschl on 23.12.21.
//

import Foundation


struct LineOfFields: Hashable, Identifiable {
    var fields: Array<Substring>
    let id = UUID()
}

struct CSVFile: Identifiable {
    let id = UUID()
    let file: String
    var lines: Array<LineOfFields>
    var fieldSeparator: Character // Usually , or ; -- to separate fields from each other
    init(file: String, fieldSeparator: Character) {
        self.file = file
        self.fieldSeparator = fieldSeparator
        self.lines = []
        print(self.parse())
    }
    mutating func parse(maxLines: Int? = nil) -> (lines: Int, fields: Int) {
        var i: String.Index = file.startIndex
        var isInField = false
        var fieldIsQuoted = false
        var fieldIsDone = false
        var lineIsDone = false
        var rangeStart: String.Index  = file.startIndex
        var rangeEnd: String.Index  = file.startIndex
        var linesCount = 0
        var fieldsCount = 0
        var fieldsInLine: Array<Substring> = []
        while i < file.endIndex && (maxLines == nil || linesCount <= maxLines!) && file[rangeStart..<i].count < 100 {
            let thisChar = file[i]
            let iNext = file.index(after: i)
            switch (inside: isInField, quoted: fieldIsQuoted) {
            case (inside: true, quoted: true):
                if thisChar == "\"" {
                    if iNext == file.endIndex {
                        //last quote of the file.
                        isInField = false
                        print("interim processed: '\(thisChar)'")
                        rangeEnd = i
                        i = iNext
                        fieldIsDone = true
                        lineIsDone = true
                    } else {
                        switch file[iNext] {
                        case fieldSeparator:
                            //regular end of the quoted field and the line.
                            rangeEnd = i
                            fieldIsDone = true
//                            following is wrong…
//                            print("interim processed: '\(thisChar)'")
//                            i = iNext
                        case "\r", "\r\n", "\n":
                            //regular end of the quoted field.
                            rangeEnd = i
                            fieldIsDone = true
                            lineIsDone = true
                            print("interim processed: '\(thisChar)'")
                            i = iNext
                        case "\"":
                            //double quote. just move on.
                            print("interim processed: '\(thisChar)'")
                            i = iNext
                        default:
                            //formatting error.
                            fieldIsQuoted = false
                        }
                    }
                    //else just move on.
                }
            case (inside: true, quoted: false):
                switch thisChar {
                case fieldSeparator:
                    fieldIsDone = true
                    rangeEnd = i
                case "\r", "\r\n", "\n":
                    fieldIsDone = true
                    lineIsDone = true
                    rangeEnd = i
                default:
                    //just move on.
                    ()
                }
            case (inside: false, quoted: true):
                switch thisChar {
                case "\"":
                    //Is this an empty field or a quoted field with a quote at the start?
                    if iNext == file.endIndex {
                        //a single quote at the end of the file?
                        rangeEnd = i
                        rangeStart = i
                        fieldIsDone = true
                        lineIsDone = true
                    } else {
                        let nextChar = file[iNext]
                        if nextChar == "\"" {
                            //its a double quote.
                            rangeStart = i
                            print("interim processed: '\(file[i])'")
                            i = iNext
                            isInField = true
                        } else {
                            //not a double quote so thisChar must be the end of the field
                            //there should be a fieldSeparator next because just empty quoted field.
                            rangeStart = i
                            rangeEnd = i
                            fieldIsDone = true
                            print("interim processed: '\(file[i])'")
                            i = iNext
                        }
                    }
                default:
                    isInField = true
                    rangeStart = i
                }

            case (inside: false, quoted: false):
                switch thisChar {
                case "\"":
                    if iNext < file.endIndex {
                        if file[iNext] == "\"" {
                            let iNext2 = file.index(after: iNext)
                            if iNext2 < file.endIndex {
                                if file[iNext2] == "\"" {
                                    //Double Quote inside a quoted field.
                                    fieldIsQuoted = true
                                } else {
                                    //empty quoted field
                                    i = iNext
                                    rangeStart = iNext
                                    rangeEnd = iNext
//                                    fieldIsDone = false
                                }
                            } else {
                                //empty quoted field at EOF.
                                rangeStart = iNext
                                rangeEnd = iNext
//                                fieldIsDone = true
                            }
                        } else {
                            fieldIsQuoted = true
                        }
                    } else {
                        //single quote at EOF?
                        rangeStart = i
                        rangeEnd = iNext
                        fieldIsDone = true
                    }
                case fieldSeparator:
                    if iNext == file.endIndex {
                        //;before end of file. Should be an empty field.
                        rangeStart = i
                        rangeEnd = i
                        isInField = true
                    } else {
                        rangeStart = i
                        rangeEnd = i
                    }
                    fieldIsDone = true
                case "\r", "\r\n", "\n":
                    rangeStart = i
                    rangeEnd = i
                    fieldIsDone = true
                    lineIsDone = true
                default:
                    rangeStart = i
                    isInField = true
                }
            }
            if !fieldIsDone {
                if file.index(after: i) == file.endIndex {
                    fieldIsDone = true
                    lineIsDone = true
                    if fieldIsQuoted {
                        rangeEnd = i
                    } else {
                        rangeEnd = file.endIndex
                    }
                }
            }
            if fieldIsDone {
                fieldIsDone = false
                if rangeStart <= rangeEnd {
                    let subString = file[rangeStart..<rangeEnd]
                    fieldsInLine.append(subString)
                    print("Field done: '\(subString)'")
                } else {
                    fatalError("Invalid range in fieldIsDone \(rangeStart)..<\(rangeEnd)")
                }
                isInField = false
                fieldIsQuoted = false
                fieldsCount += 1
            }
            if !lineIsDone {
                if file.index(after: i) == file.endIndex {
//                    fieldIsDone = true
                    lineIsDone = true
                }
            }
            if lineIsDone {
                print("Line is done")
                lines.append(LineOfFields(fields: fieldsInLine))
                fieldsInLine = []
                linesCount += 1
                lineIsDone = false
            }
            if i < file.endIndex {
                print("last processed: '\(file[i])'")
                i = file.index(after: i)
            }

        }
        return (linesCount, fieldsCount)
    }
}


