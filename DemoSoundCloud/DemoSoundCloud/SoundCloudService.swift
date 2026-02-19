
import Foundation
import AVKit
import WebKit

// MARK: - SoundCloud Service (Singleton)
final class SoundCloudService {
    
    // MARK: - Singleton
    static let shared = SoundCloudService()
    private init() {}
    
    // MARK: - Properties
    private let clientID = "rGrV2EndFwWNNgFGUOlaQzlknwiaSdte"
    private let clientSecret = "vxGOH1FPtcik8T8z9UzEVzLFLJFpytsE"
    
    private let tokenKey = "soundcloud_access_token"
    private let tokenExpiryKey = "soundcloud_token_expiry"
    
    private(set) var tracks: [MusicModel] = []
    private var nextOffset = 0
    private let pageSize = 20
    private let playCount = 0
    private var isLoading = false
    
    var accessToken: String? {
        didSet {
            guard let token = accessToken else { return }
            UserDefaults.standard.set(token, forKey: tokenKey)
        }
    }
    
    // MARK: - Public Methods
    func fetchTracks(completion: @escaping () -> Void) {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            defer { isLoading = false }
            do {
                let newTracks = try await fetchTracksAsync()
                await MainActor.run {
                    self.tracks.append(contentsOf: newTracks)
                    self.nextOffset += self.pageSize
                    print("Tracks appended:", self.tracks.count)
                    completion()
                }
            } catch {
                print("Fetch tracks error:", error)
            }
        }
    }
    
    func getTrackToPlay(track: MusicModel, completion: @escaping (URL?) -> Void) {
        let fm = FileManager.default
        guard let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }
        
        let safeFileName = track.musicName.replacingOccurrences(of: "/", with: "-") + ".mp3"
        let destination = caches.appendingPathComponent(safeFileName)
        
        // ✅ Already downloaded → play local file
        if fm.fileExists(atPath: destination.path) {
            completion(destination)
            return
        }
        
        // Before downloading, cleanup if cache size > limit
        cleanupCacheIfNeeded(maxSizeMB: 100) // Example: 100 MB limit
        
        // ⬇️ Not downloaded → download
        guard let url = URL(string: track.musicUrl),
              let token = accessToken else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.downloadTask(with: request) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                print("Download failed:", error?.localizedDescription ?? "unknown")
                completion(nil)
                return
            }
            
            do {
                try fm.moveItem(at: tempURL, to: destination)
                completion(destination)
            } catch {
                print("File move error:", error)
                completion(nil)
            }
        }
        task.resume()
    }
}

extension SoundCloudService {
    
    // MARK: - Cache cleanup helper
    private func cleanupCacheIfNeeded(maxSizeMB: Int) {
        let fm = FileManager.default
        guard let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }

        do {
            let files = try fm.contentsOfDirectory(at: caches, includingPropertiesForKeys: [.contentAccessDateKey, .fileSizeKey], options: .skipsHiddenFiles)
            var totalSize: Int64 = 0
            var fileInfos: [(url: URL, size: Int64, lastAccess: Date)] = []

            for file in files {
                let attrs = try file.resourceValues(forKeys: [.contentAccessDateKey, .fileSizeKey])
                let size = Int64(attrs.fileSize ?? 0)
                let lastAccess = attrs.contentAccessDate ?? Date.distantPast
                totalSize += size
                fileInfos.append((file, size, lastAccess))
            }

            // If total cache exceeds limit → delete oldest first
            let maxBytes = Int64(maxSizeMB) * 1024 * 1024
            if totalSize > maxBytes {
                let sortedFiles = fileInfos.sorted { $0.lastAccess < $1.lastAccess }
                var removedSize: Int64 = 0
                for file in sortedFiles {
                    try fm.removeItem(at: file.url)
                    removedSize += file.size
                    if totalSize - removedSize <= maxBytes { break }
                }
            }
        } catch {
            print("Cache cleanup error:", error)
        }
    }
    
    func loadCachedTokenAndFetch(completion: @escaping () -> Void) {
        Task { [weak self] in
            guard let self else { return }
            let defaults = UserDefaults.standard
            
            do {
                if let cachedToken = defaults.string(forKey: tokenKey),
                   let expiryDate = defaults.object(forKey: tokenExpiryKey) as? Date,
                   Date() < expiryDate {
                    self.accessToken = cachedToken
                    self.fetchTracks { completion() }
                    return
                }
                
                let token = try await fetchClientCredentialsToken()
                self.accessToken = token
                self.fetchTracks { completion() }
            } catch {
                print("Token / Fetch error:", error)
            }
        }
    }
    
    // MARK: - Private Async Methods
    private func fetchTracksAsync() async throws -> [MusicModel] {
        let token = try await loadValidToken()
        let urlString = "https://api.soundcloud.com/tracks?genres=love&limit=\(pageSize)&offset=\(nextOffset)"
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        return jsonArray.compactMap { dict in
            print(dict)
            guard let title = dict["title"] as? String,
                  let uri = dict["permalink_url"] as? String,
                  let artwork = dict["artwork_url"] as? String,
                  let durationInt = dict["duration"] as? Int else { return nil }

            let streamURL = "\(uri)/stream"
            return MusicModel(
                musicName: title,
                musicImage: artwork,
                musicUrl: uri,
                fileName: "\(durationInt)",
                musicMode: .defaultMode
            )
        }
    }
    
    private func fetchClientCredentialsToken() async throws -> String {
        guard let url = URL(string: "https://secure.soundcloud.com/oauth/token") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let authString = "\(clientID):\(clientSecret)"
        let base64 = Data(authString.utf8).base64EncodedString()
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["access_token"] as? String,
              let expiresIn = json["expires_in"] as? Double else {
            throw NSError(domain: "TokenError", code: -1)
        }
        
        let expiryDate = Date().addingTimeInterval(expiresIn)
        UserDefaults.standard.set(expiryDate, forKey: tokenExpiryKey)
        return token
    }
    
    private func loadValidToken() async throws -> String {
        if let cached = accessToken { return cached }
        let token = try await fetchClientCredentialsToken()
        accessToken = token
        return token
    }
}
