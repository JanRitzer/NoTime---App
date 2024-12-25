//
//  ContentView.swift
//  NoTime
//
//  Created by Jan Ritzer on 24.12.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userData = UserData()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(userData: userData) {
                hasCompletedOnboarding = true
            }
        } else {
            MainMenuView(userData: userData)
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var userData: UserData
    let onComplete: () -> Void
    @State private var name = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding(.top, 40)
            
            Text("Willkommen zum\nStudienkalender!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Organisiere deine Prüfungen und behalte deinen Lernfortschritt im Blick.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Wie ist dein Name?", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .padding(.horizontal)
                .frame(maxWidth: 400)
                .padding(.top, 20)
            
            Button(action: {
                userData.name = name
                onComplete()
            }) {
                Text("Los geht's!")
                    .font(.headline)
                    .frame(minWidth: 200, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct MainMenuView: View {
    @ObservedObject var userData: UserData
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        let name = userData.name.isEmpty ? "" : ", \(userData.name)"
        
        switch hour {
        case 0..<5: return "Gute Nacht\(name)"
        case 5..<12: return "Guten Morgen\(name)"
        case 12..<18: return "Guten Tag\(name)"
        default: return "Guten Abend\(name)"
        }
    }
    
    var body: some View {
        TabView {
            CalendarView(userData: userData)
                .tabItem {
                    Label("Kalender", systemImage: "calendar")
                }
            
            ExamListView(userData: userData)
                .tabItem {
                    Label("Prüfungen", systemImage: "list.clipboard")
                }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(greeting)
                            .font(.title)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .tabItem {
                Label("Profil", systemImage: "person.circle")
            }
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
}

struct CalendarView: View {
    @ObservedObject var userData: UserData
    @State private var selectedDate = Date()
    
    private var examsByDate: [Date: [Exam]] {
        Dictionary(grouping: userData.exams) { exam in
            Calendar.current.startOfDay(for: exam.date)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Datum auswählen",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .overlay {
                    GeometryReader { geometry in
                        ForEach(Array(examsByDate.keys), id: \.self) { date in
                            if let dayView = findDayView(for: date, in: geometry) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .position(x: dayView.minX + dayView.width/2,
                                            y: dayView.minY + dayView.height - 6)
                            }
                        }
                    }
                }
                
                List {
                    ForEach(examsByDate.keys.sorted(), id: \.self) { date in
                        if let exams = examsByDate[date] {
                            Section(header: Text(formatDate(date))) {
                                ForEach(exams) { exam in
                                    ExamRow(userData: userData, exam: exam)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kalender")
        }
    }
    
    private func findDayView(for date: Date, in geometry: GeometryProxy) -> CGRect? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let dateString = String(format: "%d-%02d-%02d", 
                              components.year!, 
                              components.month!, 
                              components.day!)
        
        return geometry.findView(withId: dateString)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}

// Hilfserweiterung für GeometryProxy
extension GeometryProxy {
    func findView(withId id: String) -> CGRect? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let view = child.value as? UIView {
                if let targetView = view.findView(withId: id) {
                    return targetView.convert(targetView.bounds, to: nil)
                }
            }
        }
        return nil
    }
}

// Hilfserweiterung für UIView
extension UIView {
    func findView(withId id: String) -> UIView? {
        if accessibilityIdentifier == id {
            return self
        }
        for subview in subviews {
            if let found = subview.findView(withId: id) {
                return found
            }
        }
        return nil
    }
}

struct ExamListView: View {
    @ObservedObject var userData: UserData
    @State private var showingAddExam = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.exams) { exam in
                    ExamRow(userData: userData, exam: exam)
                }
            }
            .navigationTitle("Prüfungen")
            .toolbar {
                Button(action: { showingAddExam = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddExam) {
                AddExamView(userData: userData)
            }
        }
    }
}

struct ExamRow: View {
    @ObservedObject var userData: UserData
    let exam: Exam
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    var timeUntilExam: (days: Int, hours: Int, minutes: Int) {
        Calendar.current.timeUntil(from: currentDate, to: exam.fullDateTime)
    }
    
    var body: some View {
        NavigationLink(destination: ExamDetailView(userData: userData, exam: exam)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(exam.subject)
                        .font(.headline)
                    Spacer()
                    Text(formatter.string(from: exam.fullDateTime))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundStyle(.blue)
                    Text("\(timeUntilExam.days)d \(timeUntilExam.hours)h \(timeUntilExam.minutes)m")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !exam.topics.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(PreparationLevel.allCases, id: \.self) { level in
                            let count = exam.topics.filter { $0.preparationLevel == level }.count
                            if count > 0 {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(level.color)
                                        .frame(width: 8, height: 8)
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Spacer()
                        Text("\(exam.topics.count) Themen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
}

struct AddExamView: View {
    @ObservedObject var userData: UserData
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""
    @State private var date = Date()
    @State private var time = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Prüfungsfach", text: $subject)
                
                DatePicker("Datum", selection: $date, displayedComponents: .date)
                
                DatePicker("Uhrzeit", selection: $time, displayedComponents: .hourAndMinute)
            }
            .navigationTitle("Neue Prüfung")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Speichern") {
                    let exam = Exam(subject: subject, date: date, time: time)
                    userData.exams.append(exam)
                    dismiss()
                }
                .disabled(subject.isEmpty)
            )
        }
    }
}

struct ExamDetailView: View {
    @ObservedObject var userData: UserData
    let exam: Exam
    @State private var showingAddTopic = false
    @State private var newTopicName = ""
    
    var examIndex: Int {
        userData.exams.firstIndex(where: { $0.id == exam.id }) ?? 0
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text(formatDateTime(exam.fullDateTime))
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.blue)
                        Text(formatTimeUntil(exam))
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                ForEach(exam.topics) { topic in
                    TopicRow(topic: topic) { newLevel in
                        if let topicIndex = userData.exams[examIndex].topics.firstIndex(where: { $0.id == topic.id }) {
                            userData.exams[examIndex].topics[topicIndex].preparationLevel = newLevel
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Lernthemen")
                    Spacer()
                    Button(action: { showingAddTopic = true }) {
                        Label("Hinzufügen", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .navigationTitle(exam.subject)
        .alert("Neues Thema", isPresented: $showingAddTopic) {
            TextField("Themenname", text: $newTopicName)
            Button("Abbrechen", role: .cancel) {
                newTopicName = ""
            }
            Button("Hinzufügen") {
                let newTopic = Topic(name: newTopicName)
                userData.exams[examIndex].topics.append(newTopic)
                newTopicName = ""
            }
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
    
    private func formatTimeUntil(_ exam: Exam) -> String {
        let time = Calendar.current.timeUntil(from: Date(), to: exam.fullDateTime)
        return "\(time.days) Tage, \(time.hours) Stunden, \(time.minutes) Minuten"
    }
}

struct TopicRow: View {
    let topic: Topic
    let onLevelChange: (PreparationLevel) -> Void
    
    var body: some View {
        HStack {
            Text(topic.name)
            Spacer()
            HStack(spacing: 12) {
                ForEach([PreparationLevel.red, .yellow, .green], id: \.self) { level in
                    Circle()
                        .fill(level.color)
                        .frame(width: 24, height: 24)
                        .opacity(topic.preparationLevel == level ? 1.0 : 0.3)
                        .onTapGesture {
                            onLevelChange(level)
                        }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
