//
//  UIImageView+extension.swift
//  SaikoTestTask
//
//  Created by Вадим Сайко on 4.07.23.
//

import UIKit

extension UIImageView {
    
    func downloaded(from url: String, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                return
            }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
}
