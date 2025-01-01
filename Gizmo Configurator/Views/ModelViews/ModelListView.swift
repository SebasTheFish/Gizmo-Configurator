//
//  DeviceListView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ModelListView: View {
    @Environment(DeviceRepository.self) var modelRepo
    @State var addPresented: Bool = false
    @State var presentExporter: Bool = false
    @State var presentImporter: Bool = false
    @State var document = TextFile()
    
    var body: some View {
        VStack {
            if modelRepo.models.count != 0 {
                List(modelRepo.models) { model in
                    NavigationLink(value: model) {
                        VStack(alignment: .leading) {
                            Text(model.name)
                        }
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            modelRepo.unregisterModel(model: model)
                        }
                        Button("Export") {
                            document = TextFile(model: model)
                            presentExporter = true
                        }
                        .tint(Color.accentColor)
                    }
                }
            }
            else {
                ContentUnavailableView("No Devices in Library", systemImage: "books.vertical.fill", description: Text("Please add a device to get started"))
                    .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Add New Device") {
                        addPresented = true
                    }
                    Button("Import Device From File") {
                        presentImporter = true
                    }
                } label: {
                    Label("", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $addPresented) {
            ModelAddView(modelRepo: modelRepo, isPresented: $addPresented)
        }
        .navigationTitle("Device Library")
        .navigationDestination(for: Device.self) { model in
            ModelDetailsView(model: model)
        }
        .navigationDestination(for: DatumGroup.self) { group in
            GroupDetailsView(group: group)
        }
        .navigationDestination(for: Datum.self) { datum in
            DatumDetailsView(datum: datum)
        }
        .fileExporter(
            isPresented: $presentExporter,
            document: document,
            contentType: .json
        ) { result in
            switch result {
            case .success(_):
                ()
            case .failure(let error):
                print(error)
            }
        }
        .fileImporter(
            isPresented: $presentImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { res in
            switch res {
            case .success(let urls):
                for url in urls {
                    do {
                        // Get permission to open file
                        let accessing = url.startAccessingSecurityScopedResource()
                        
                        // Defer releasing the file
                        defer {
                            if accessing {
                                url.stopAccessingSecurityScopedResource()
                            }
                        }
                        // Read the model from the file
                        let data = try Data(contentsOf: url)
                        let model = try JSONDecoder().decode(Device.self, from: data)
                        
                        // Add the model to the repo
                        modelRepo.registerModel(model: model)
                    }
                    catch (let error) {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct TextFile: FileDocument {
    static var readableContentTypes = [UTType.json]
    var data: Device

    init(model: Device) {
        self.data = model
    }
    
    init() {
        self.data = Device(name: "")
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.data = try JSONDecoder().decode(Device.self, from: data)
        }
        data = Device(name: "")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let json = try JSONEncoder().encode(data)
        let doc = FileWrapper(regularFileWithContents: json)
        doc.filename = "\(data.name).json"
        return doc
    }
}

//#Preview {
//    let modelRepo: DeviceRepository = DeviceRepository(modelContext: .init(.init(for: Device.self)), demo: true)
//    
//    NavigationStack {
//        ModelListView()
//    }
//    .environment(modelRepo)
//}
