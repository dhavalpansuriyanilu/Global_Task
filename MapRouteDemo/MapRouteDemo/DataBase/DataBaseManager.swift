import Foundation
import CoreData
import UIKit

class DataBaseManager {
    
    static let shared = DataBaseManager()
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocationRouteData") // Database name
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Add New Route
    func addLocationRoute(model: LocationRouteModel) {
        let newRoute = LocationRoutes(context: context)
        newRoute.id = model.id
        newRoute.fromLocationName = model.fromLocation
        newRoute.toLocationName = model.toLocation
        newRoute.imageName = model.imageName
        saveContext()
    }

    
    // MARK: - Fetch All Location Routes
    func fetchAllLocationRoutes() -> [LocationRouteModel] {
        let fetchRequest: NSFetchRequest<LocationRoutes> = LocationRoutes.fetchRequest()
        
        do {
            let fetchedRoutes = try context.fetch(fetchRequest)
            return fetchedRoutes.map { route in
                LocationRouteModel(
                    id: route.id ?? UUID(),
                    fromLocation: route.fromLocationName ?? "",
                    toLocation: route.toLocationName ?? "",
                    imageName: route.imageName ?? ""
                )
            }
        } catch {
            print("Failed to fetch LocationRoutes: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Fetch Location Route by ID
    func fetchLocationRoute(byID id: UUID) -> LocationRoutes? {
        let fetchRequest: NSFetchRequest<LocationRoutes> = LocationRoutes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch LocationRoutes: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Update Location Route by Model
    func updateLocationRoute(with model: LocationRouteModel) {
        if let route = fetchLocationRoute(byID: model.id) {
            route.fromLocationName = model.fromLocation
            route.toLocationName = model.toLocation
            route.imageName = model.imageName
            saveContext()
        } else {
            print("No record found with the given ID.")
        }
    }

    
    // MARK: - Delete Location Route by ID
    func deleteLocationRoute(byID id: UUID) {
        if let route = fetchLocationRoute(byID: id) {
            context.delete(route)
            saveContext()
        } else {
            print("No record found with the given ID.")
        }
    }
}
