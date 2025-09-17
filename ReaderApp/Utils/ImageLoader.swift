//
//  ImageLoader.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    
    func load(url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else { completion(nil); return }
        if let img = cache.object(forKey: url as NSURL) { completion(img); return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let img = UIImage(data: data)
                if let img = img { cache.setObject(img, forKey: url as NSURL) }
                DispatchQueue.main.async { completion(img) }
            } catch {
                print("[ImageLoader] error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}

