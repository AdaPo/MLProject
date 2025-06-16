//
//  IncomeClassificationView.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 03.05.2023.
//

import SwiftUI
import CoreML

struct IncomeClassificationView: View {
     var workclasses = ["Private", "Self-emp-not-inc", "Self-emp-inc", "Federal-gov", "Local-gov", "State-gov", "Without-pay", "Never-worked"]
     var education = ["Bachelors", "Some-college", "11th", "HS-grad", "Prof-school", "Assoc-acdm", "Assoc-voc", "9th", "7th-8th", "12th", "Masters", "1st-4th", "10th", "Doctorate", "5th-6th", "Preschool"]
     var maritalStatus = [ "Married-civ-spouse", "Divorced", "Never-married", "Separated", "Widowed", "Married-spouse-absent", "Married-AF-spouse"]
     var occupation = ["Tech-support", "Craft-repair", "Other-service", "Sales", "Exec-managerial", "Prof-specialty", "Handlers-cleaners", "Machine-op-inspct", "Adm-clerical", "Farming-fishing", "Transport-moving", "Priv-house-serv", "Protective-serv", "Armed-Forces"]
     var relationship = ["Wife", "Own-child", "Husband", "Not-in-family", "Other-relative", "Unmarried"]
     var race = ["White", "Asian-Pac-Islander", "Amer-Indian-Eskimo", "Other", "Black"]
     var sex = ["Female", "Male"]
     var nativeCountry = ["United-States", "Cambodia", "England", "Puerto-Rico", "Canada", "Germany", "Outlying-US(Guam-USVI-etc)", "India", "Japan", "Greece", "South", "China", "Cuba", "Iran", "Honduras", "Philippines", "Italy", "Poland", "Jamaica", "Vietnam", "Mexico", "Portugal", "Ireland", "France", "Dominican-Republic", "Laos", "Ecuador", "Taiwan", "Haiti", "Columbia", "Hungary", "Guatemala", "Nicaragua", "Scotland", "Thailand", "Yugoslavia", "El-Salvador", "Trinadad&Tobago", "Peru", "Hong", "Holand-Netherlands"]
    @State  var age = 25
    @State  var selectedWorkClass: String = "Private"
    @State  var selectedEductaion: String = "Bachelors"
    @State  var selectedMaritalStatus: String = "Married-civ-spouse"
    @State  var selectedOccupation: String = "Tech-support"
    @State  var selectedRelationship: String = "Wife"
    @State  var selectedRace: String = "White"
    @State  var selectedSex: String = "Male"
    @State  var selectedCountry: String = "United-States"
    @State  var capitalGain = 0.0
    @State  var capitalLoss = 0.0
    @State  var hoursWeekly = 0.0
    
    
    @State var result: String = ""
    @State var modelSource: ModelSource = .coreMl
    var classify: (()->Void)

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Form {
                    Group {
                        HStack() {
                            Text("Age")
                            Spacer()
                            TextField("", value: $age, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                        }
                        Picker("Workclass", selection: $selectedWorkClass) {
                            ForEach(workclasses, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Education", selection: $selectedEductaion) {
                            ForEach(education, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Marital Status", selection: $selectedMaritalStatus) {
                            ForEach(maritalStatus, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Occupation", selection: $selectedOccupation) {
                            ForEach(occupation, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Relationship", selection: $selectedRelationship) {
                            ForEach(relationship, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    Group {
                        Picker("Race", selection: $selectedRace) {
                            ForEach(race, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Sex", selection: $selectedSex) {
                            ForEach(sex, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Native country", selection: $selectedCountry) {
                            ForEach(nativeCountry, id: \.self) {
                                Text($0)
                            }
                        }
                        Group {
                            HStack() {
                                Text("Capital gain")
                                Spacer()
                                TextField("", value: $capitalGain, format: .number)
                                    .frame(alignment: .trailing)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 50)
                            }
                            HStack() {
                                Text("Capital loss")
                                Spacer()
                                TextField("", value: $capitalLoss, format: .number)
                                    .frame(alignment: .trailing)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 50)

                            }
                            HStack() {
                                Text("Hours weekly")
                                Spacer()
                                TextField("", value: $hoursWeekly, format: .number)
                                    .frame(alignment: .trailing)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 50)
                            }
                        }
                        VStack {
                            Text("Selected the source of ML Model")
                            Picker("Select model source", selection: $modelSource) {
                                ForEach(ModelSource.allCases, id: \.self) { value in
                                    Text(value.rawValue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .pickerStyle(.segmented)
                        }
                        
                        Text("Income over 50k: \(result)")
                    }
                        Section {
                            EmptyView()
                        } footer: {
                            Button {
                                classifyIncome()
                            } label: {
                                Text("Classify")
                                    .font(.body)
                            }
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.gray)
                            .cornerRadius(8)
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
            }
        }
    }
    
    func classifyIncome() {
        if modelSource == .coreMl {
            print("coreML")
            do {
                let config = MLModelConfiguration()
                let model = try IncomeClassificationModel(configuration: config)
                let prediction = try model.prediction(
                    age: Double(self.age),
                    workclass: self.selectedWorkClass,
                    education: self.selectedEductaion,
                    maritalStatus: self.selectedMaritalStatus,
                    occupation: self.selectedOccupation,
                    relationship: self.selectedRelationship,
                    race: self.selectedRace,
                    sex: self.selectedSex,
                    capitalGain: self.capitalGain,
                    capitalLoss: self.capitalLoss,
                    hoursPerWeek: self.hoursWeekly,
                    country: self.selectedCountry
                )
                let result = prediction.target
                self.result = result
                print(result)
            } catch {
                print("Error happened.")
            }
        } else if modelSource == .bigMl {
            BigMLConnector().makePredictionIncome(incomeModel: IncomeModel(
                age: self.age, workClass: self.selectedWorkClass, education: self.selectedEductaion, maritalStatus: self.selectedMaritalStatus, occupation: self.selectedOccupation, relationship: selectedRelationship, race: selectedRace, sex: selectedSex, capitalGain: Int(capitalGain), capitalLoss: Int(capitalLoss), hoursPerWeek: Int(hoursWeekly))) { result in
                    self.result = result
                }
            print(result)
        }
    }
    
    func test() {
        let featureColumns = MetadataLoader.loadFeatureColumns()
        let scalerParams = MetadataLoader.loadScalerParams()

        let input: [String: Any] = [
            "age": Double(self.age),

            "education": self.selectedEductaion,
            "hours-per-week": self.hoursWeekly,
            "workclass": self.selectedWorkClass,
            "marital-status": self.selectedMaritalStatus,
            "occupation": self.selectedOccupation,
            "relationship":self.selectedRelationship,
            "race": self.selectedRace,
            "sex":  self.selectedSex,
            "native-country": self.selectedCountry
        ]
        

        //le/*t inputVector = encodeInput(sampleInput, featureColumns: featureColumns, scalerParams: scalerParams)*/
        // Pass inputVector to TFLite model

    }
}

struct IncomeClassificationView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeClassificationView(classify: {})
    }
}
