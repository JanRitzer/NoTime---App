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
    @State private var showGreeting = true
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(userData: userData) {
                hasCompletedOnboarding = true
            }
        } else {
            MainMenuView(userData: userData)
                .overlay {
                    if showGreeting {
                        GeometryReader { geometry in
        VStack {
                                VStack(spacing: 8) {
                                    Image(systemName: getGreetingIcon())
                                        .font(.system(size: 44))
                                        .foregroundStyle(.yellow)
                                        .symbolEffect(.bounce, options: .repeat(2))
                                        .padding(.bottom, 4)
                                    
                                    Text(getGreeting())
                                        .font(.title2.bold())
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Schön, dass du wieder da bist!")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 24)
                                .frame(maxWidth: min(geometry.size.width - 32, 400))
                                .background(
                                    Color(.systemBackground)
                                        .shadow(
                                            color: colorScheme == .light ? .black.opacity(0.05) : .clear,
                                            radius: 10,
                                            x: 0,
                                            y: 5
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, geometry.safeAreaInsets.top + 20)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showGreeting = false
                                }
                            }
                        }
                    }
                }
        }
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userData.name
        
        // Verbesserte Formatierung der Begrüßung
        switch hour {
        case 0..<5: return "Gute Nacht,\n\(name)"
        case 5..<12: return "Guten Morgen,\n\(name)"
        case 12..<18: return "Guten Tag,\n\(name)"
        default: return "Guten Abend,\n\(name)"
        }
    }
    
    private func getGreetingIcon() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<5: return "moon.zzz.fill"
        case 5..<12: return "sun.max.fill"
        case 12..<18: return "sun.max.fill"
        default: return "moon.stars.fill"
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var userData: UserData
    let onComplete: () -> Void
    @State private var name = ""
    @State private var email = ""
    @State private var currentStep = 0
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 24) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                            .padding(.top, geometry.safeAreaInsets.top + 60)
                            .symbolEffect(.bounce.up, options: .speed(0.5), value: isAnimating)
                        
                        VStack(spacing: 16) {
                            Text("Willkommen zum\nStudienkalender!")
                                .font(.system(size: 34, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .opacity(isAnimating ? 1 : 0)
                                .offset(y: isAnimating ? 0 : 20)
                            
                            Text("Organisiere deine Prüfungen und behalte deinen Lernfortschritt im Blick.")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .opacity(isAnimating ? 1 : 0)
                                .offset(y: isAnimating ? 0 : 15)
                        }
                    }
                    
                    // Content
                    TabView(selection: $currentStep) {
                        // Name Step
                        VStack(spacing: 32) {
                            VStack(alignment: .center, spacing: 8) {
                                Text("Wie heißt du?")
                                    .font(.title2.bold())
                                
                                Text("Dein Name wird für persönliche Begrüßungen verwendet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 24) {
                                TextField("", text: $name)
                                    .textFieldStyle(.plain)
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                    )
                                    .placeholder(when: name.isEmpty) {
                                        Text("Dein Name")
                                            .foregroundColor(.secondary.opacity(0.8))
                                            .font(.title3)
                                    }
                                
                                Button(action: {
                                    withAnimation(.spring(duration: 0.5)) {
                                        currentStep = 1
                                    }
                                }) {
                                    Text("Weiter")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                        .background(name.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .disabled(name.isEmpty)
                            }
                            .padding(.horizontal, 24)
                        }
                        .tag(0)
                        
                        // Email Step
                        VStack(spacing: 32) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Deine E-Mail-Adresse")
                                    .font(.title2.bold())
                                
                                Text("Optional: Für zukünftige Features und Benachrichtigungen")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 24) {
                                TextField("", text: $email)
                                    .textFieldStyle(.plain)
                                    .font(.title3)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                    )
                                    .placeholder(when: email.isEmpty) {
                                        Text("beispiel@email.de")
                                            .foregroundColor(.secondary.opacity(0.8))
                                            .font(.title3)
                                    }
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                
                                Button(action: {
                                    withAnimation {
                                        userData.name = name
                                        userData.email = email.isEmpty ? nil : email
                                        onComplete()
                                    }
                                }) {
                                    Text("Los geht's!")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 300)
                }
                .frame(minHeight: geometry.size.height)
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// Helper View für Placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct MainMenuView: View {
    @ObservedObject var userData: UserData
    @State private var currentDate = Date()
    @State private var showingEditProfile = false
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
            
            NavigationView {
                List {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(greeting)
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section("Profil-Einstellungen") {
                        HStack {
                            Label("Name", systemImage: "person")
                            Spacer()
                            Text(userData.name)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingEditProfile = true
                        }
                        
                        if let email = userData.email {
                            HStack {
                                Label("E-Mail", systemImage: "envelope")
                                Spacer()
                                Text(email)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Section {
                        NavigationLink(destination: StatisticsView(userData: userData)) {
                            Label("Statistiken", systemImage: "chart.bar")
                        }
                        
                        NavigationLink(destination: SettingsView(userData: userData)) {
                            Label("Einstellungen", systemImage: "gear")
                        }
                    }
                }
                .navigationTitle("Profil")
            }
            .tabItem {
                Label("Profil", systemImage: "person.circle")
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(userData: userData)
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
}

struct EditProfileView: View {
    @ObservedObject var userData: UserData
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var email: String
    
    init(userData: UserData) {
        self.userData = userData
        _name = State(initialValue: userData.name)
        _email = State(initialValue: userData.email ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Persönliche Daten") {
                    TextField("Name", text: $name)
                    TextField("E-Mail", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("Speichern") {
                        userData.name = name
                        userData.email = email.isEmpty ? nil : email
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Profil bearbeiten")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() }
            )
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
            ScrollView {
                VStack(spacing: 20) {
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
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        ForEach(examsByDate.keys.sorted(), id: \.self) { date in
                            if let exams = examsByDate[date] {
                                Section {
                                    VStack(spacing: 12) {
                                        ForEach(exams) { exam in
                                            ExamRow(userData: userData, exam: exam)
                                                .padding(.horizontal)
                                                .background(Color(.systemBackground))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                } header: {
                                    Text(formatDate(date))
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(.ultraThinMaterial)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
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
    
    private var preparationProgress: (green: Double, yellow: Double, red: Double) {
        let totalMinutes = exam.topics.reduce(0) { $0 + $1.estimatedMinutes }
        guard totalMinutes > 0 else { return (0, 0, 0) }
        
        let greenMinutes = exam.topics
            .filter { $0.preparationLevel == .green }
            .reduce(0) { $0 + $1.estimatedMinutes }
        
        let yellowMinutes = exam.topics
            .filter { $0.preparationLevel == .yellow }
            .reduce(0) { $0 + $1.estimatedMinutes }
        
        let redMinutes = exam.topics
            .filter { $0.preparationLevel == .red }
            .reduce(0) { $0 + $1.estimatedMinutes }
        
        return (
            Double(greenMinutes) / Double(totalMinutes),
            Double(yellowMinutes) / Double(totalMinutes),
            Double(redMinutes) / Double(totalMinutes)
        )
    }
    
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
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geometry in
                            HStack(spacing: 2) {
                                Rectangle()
                                    .fill(PreparationLevel.green.color)
                                    .frame(width: geometry.size.width * preparationProgress.green)
                                Rectangle()
                                    .fill(PreparationLevel.yellow.color)
                                    .frame(width: geometry.size.width * preparationProgress.yellow)
                                Rectangle()
                                    .fill(PreparationLevel.red.color)
                                    .frame(width: geometry.size.width * preparationProgress.red)
                            }
                            .frame(height: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .frame(height: 6)
                        
                        HStack {
                            ForEach(PreparationLevel.allCases.reversed(), id: \.self) { level in
                                let minutes = exam.topics
                                    .filter { $0.preparationLevel == level }
                                    .reduce(0) { $0 + $1.estimatedMinutes }
                                let totalMinutes = exam.topics.reduce(0) { $0 + $1.estimatedMinutes }
                                
                                if minutes > 0 {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(level.color)
                                            .frame(width: 8, height: 8)
                                        Text("\(Int(round(Double(minutes) / Double(totalMinutes) * 100)))% (\(formatMinutes(minutes)))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    if level != .red {
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            return "\(hours)h"
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

struct AddTopicView: View {
    @ObservedObject var userData: UserData
    let examIndex: Int
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var estimatedMinutes = 60
    
    var body: some View {
        NavigationView {
            Form {
                Section("Thema") {
                    TextField("Name", text: $name)
                }
                
                Section("Vorbereitungszeit") {
                    Stepper(value: $estimatedMinutes, in: 15...480, step: 15) {
                        VStack(alignment: .leading) {
                            Text("Geschätzte Lernzeit")
                            Text(formatMinutes(estimatedMinutes))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Thema hinzufügen")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Hinzufügen") {
                    let topic = Topic(
                        name: name,
                        preparationLevel: .red,
                        estimatedMinutes: estimatedMinutes
                    )
                    userData.exams[examIndex].topics.append(topic)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours == 0 {
            return "\(minutes) Minuten"
        } else if remainingMinutes == 0 {
            return "\(hours) Stunden"
        }
        return "\(hours) Std. \(remainingMinutes) Min."
    }
}

// Vereinfachte Version der ExamDetailView
struct ExamDetailView: View {
    @ObservedObject var userData: UserData
    let exam: Exam
    let examIndex: Int
    @State private var showingAddTopic = false
    @State private var showingEditExam = false
    @State private var editedSubject: String
    @State private var editedDate: Date
    @State private var editedTime: Date
    
    init(userData: UserData, exam: Exam) {
        self.userData = userData
        self.exam = exam
        self.examIndex = userData.exams.firstIndex(where: { $0.id == exam.id }) ?? 0
        _editedSubject = State(initialValue: exam.subject)
        _editedDate = State(initialValue: exam.date)
        _editedTime = State(initialValue: exam.time)
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
                    TopicRow(
                        topic: topic,
                        onLevelChange: { newLevel in
                            if let topicIndex = userData.exams[examIndex].topics.firstIndex(where: { $0.id == topic.id }) {
                                userData.exams[examIndex].topics[topicIndex].preparationLevel = newLevel
                            }
                        },
                        examIndex: examIndex,
                        userData: userData
                    )
                }
                
                Button(action: { showingAddTopic = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Thema hinzufügen")
                    }
                }
            }
        }
        .navigationTitle(exam.subject)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showingAddTopic = true }) {
                        Label("Thema hinzufügen", systemImage: "plus")
                    }
                    
                    Button(action: { showingEditExam = true }) {
                        Label("Prüfung bearbeiten", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        userData.exams.remove(at: examIndex)
                    } label: {
                        Label("Prüfung löschen", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddTopic) {
            AddTopicView(userData: userData, examIndex: examIndex)
        }
        .sheet(isPresented: $showingEditExam) {
            NavigationView {
                Form {
                    Section("Prüfung") {
                        TextField("Name", text: $editedSubject)
                    }
                    
                    Section("Datum & Zeit") {
                        DatePicker("Datum", selection: $editedDate, displayedComponents: .date)
                        DatePicker("Uhrzeit", selection: $editedTime, displayedComponents: .hourAndMinute)
                    }
                }
                .navigationTitle("Prüfung bearbeiten")
                .navigationBarItems(
                    leading: Button("Abbrechen") {
                        showingEditExam = false
                    },
                    trailing: Button("Speichern") {
                        userData.exams[examIndex].subject = editedSubject
                        userData.exams[examIndex].date = editedDate
                        userData.exams[examIndex].time = editedTime
                        showingEditExam = false
                    }
                    .disabled(editedSubject.isEmpty)
                )
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
    let examIndex: Int
    @ObservedObject var userData: UserData
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            // Name und Notizen-Button
            VStack(alignment: .leading) {
                Text(topic.name)
                if !topic.notes.isEmpty {
                    Text("Notizen vorhanden")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onTapGesture {
                showingDetail = true
            }
            
            Spacer()
            
            // Preparation Level Menu
            ForEach(PreparationLevel.allCases, id: \.self) { level in
                Circle()
                    .fill(topic.preparationLevel == level ? level.color : level.color.opacity(0.2))
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        onLevelChange(level)
                    }
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let topicIndex = userData.exams[examIndex].topics.firstIndex(where: { $0.id == topic.id }) {
                TopicDetailView(userData: userData, examIndex: examIndex, topicIndex: topicIndex)
            }
        }
    }
}

struct TopicDetailView: View {
    @ObservedObject var userData: UserData
    let examIndex: Int
    let topicIndex: Int
    @State private var notes: String
    @State private var name: String
    @Environment(\.dismiss) var dismiss
    
    init(userData: UserData, examIndex: Int, topicIndex: Int) {
        self.userData = userData
        self.examIndex = examIndex
        self.topicIndex = topicIndex
        _notes = State(initialValue: userData.exams[examIndex].topics[topicIndex].notes)
        _name = State(initialValue: userData.exams[examIndex].topics[topicIndex].name)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("Thema", text: $name)
                }
                
                Section("Notizen") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section("Dokumente") {
                    // Hier könnte später die Dokumenten-Upload-Funktion implementiert werden
                    Text("Dokumenten-Upload kommt bald...")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Thema bearbeiten")
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    dismiss()
                },
                trailing: Button("Speichern") {
                    userData.exams[examIndex].topics[topicIndex].name = name
                    userData.exams[examIndex].topics[topicIndex].notes = notes
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct StatisticsView: View {
    @ObservedObject var userData: UserData
    
    private var totalExams: Int {
        userData.exams.count
    }
    
    private var totalTopics: Int {
        userData.exams.reduce(0) { $0 + $1.topics.count }
    }
    
    private var preparationLevels: [PreparationLevel: Int] {
        var levels: [PreparationLevel: Int] = [:]
        for exam in userData.exams {
            for topic in exam.topics {
                levels[topic.preparationLevel, default: 0] += 1
            }
        }
        return levels
    }
    
    private var totalEstimatedTime: Int {
        userData.exams.reduce(0) { examSum, exam in
            examSum + exam.topics.reduce(0) { topicSum, topic in
                topicSum + topic.estimatedMinutes
            }
        }
    }
    
    var body: some View {
        List {
            Section("Übersicht") {
                HStack {
                    Label("Prüfungen", systemImage: "list.clipboard")
                    Spacer()
                    Text("\(totalExams)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("Lernthemen", systemImage: "book")
                    Spacer()
                    Text("\(totalTopics)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("Geschätzte Gesamtlernzeit", systemImage: "clock")
                    Spacer()
                    Text(formatMinutes(totalEstimatedTime))
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Lernfortschritt") {
                ForEach(PreparationLevel.allCases, id: \.self) { level in
                    HStack {
                        Circle()
                            .fill(level.color)
                            .frame(width: 12, height: 12)
                        Text(level.description)
                        Spacer()
                        Text("\(preparationLevels[level, default: 0])")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Statistiken")
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours == 0 {
            return "\(minutes) Minuten"
        } else if remainingMinutes == 0 {
            return "\(hours) Stunden"
        }
        return "\(hours) Std. \(remainingMinutes) Min."
    }
}

struct SettingsView: View {
    @ObservedObject var userData: UserData
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var body: some View {
        List {
            Section("App") {
                Button(role: .destructive) {
                    hasCompletedOnboarding = false
                } label: {
                    Label("Onboarding wiederholen", systemImage: "arrow.clockwise")
                }
            }
            
            Section("Über") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Einstellungen")
    }
}

#Preview {
    ContentView()
}
