# Swift .csv parser
Taking a string containing a csv file and split it into records (aka lines) containing fields of data (aka Array of SubStrings). 
Parsing the contents of the fields into "proper" data types like Int, Float, Date, … should be done in an additional step, which is outside of the scope of this parser. Especially there is no check whether all fields in the same row can be converted into a valid type. 

## Spec
The parsing is done adhering to https://github.com/parsecsv/csv-spec. In some cases this parser is a little more generous, especially in handling wrongly quoted fields.

A parsing error is reported when the number of fields is not identical for all lines or in some unrecoverable cases of improperly quoted fields. The parsing is not stopped by an error.

## Usage
1. Read file and convert into String.
2. Initialize a Struct copying the file String:
```
let csvFile = CSVFile(file: rawFile, fieldSeparator: ";", tryMaxLines: 5)
```
3. You get a struct like this filled with the data:
```
struct CSVFile {
  let file: String
  var lines: Array<LineOfFields>
  var fieldSeparator: Character // Usually , or ; -- to separate fields from each other
  var errorFree: Bool = true
  init(file: String, fieldSeparator: Character = ",", tryMaxLines maxLines: Int? = nil) {
    self.file = file
    self.fieldSeparator = fieldSeparator
    self.lines = []
    self.parse(maxLines)
}
  
struct LineOfFields: Hashable, Identifiable {
    var fields: Array<Substring>
    let id = UUID()
}
```

If tryMaxLines is set to `nil` the file is parsed until end of file is hit. If it is set to an `Int` the parsing stops after finding this number of lines. This can be handy if you can't be certain of the correct `fieldSeparator` yet.

If you want to try a different `fieldSeparator` just set the var accordingly and then call the `mutating func parse(maxLines: Int? = nil)` on the struct.

Good luck.

## Escaping Quotes
For preformance reasons we're using `Substring`s. That means the parser cannot unescape double double quotes ("") into single double (") quotes. That has to be done while converting the Arrays of Substrings into proper data.
Quick and dirty example how to do this, here in the context of a simple SwiftUI View:
```
ForEach(line.fields, id:\.self) { field in
  Text(field.replacingOccurrences(of: "\"\"", with: "\""))
```
Note: direct usage of the Substrings in a SwiftUI ForEach like this is not recommended for production because
```
the ID  occurs multiple times within the collection, this will give undefined results!
```
Don't do like I do. ;-)

## Testing / trying
There is a ContentView.swift file with around 30 test "files" in it to try inside an Xcode iPhone App Project. It's a little hacky but it did get the job done to debug the parser pretty okay.

## Known issue
If a field is improperly quoted (it has an opening double quote (") but no such closing quote before end of file) then the last character of this field (which should be the closing double quote) is omitted. 

