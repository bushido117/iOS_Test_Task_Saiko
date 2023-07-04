//
//  ViewController.swift
//  SaikoTestTask
//
//  Created by Вадим Сайко on 30.06.23.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {
    
    private lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        return picker
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            MainTableViewCell.self,
            forCellReuseIdentifier: String(describing: MainTableViewCell.self)
        )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var getModel: GetModel?
    private var isFetchingNextPage = false
    private var currentPage = 0
    private var choosenCell = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        APIService.loadData(for: currentPage, type: getModel) { [weak self] result in
            switch result {
            case .success(let success):
                self?.getModel = success
                DispatchQueue.main.async {
                    self?.addSubviews()
                    self?.setupConstraints()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func fetchNextPage() {
        guard !isFetchingNextPage else {
            return
        }
        isFetchingNextPage = true
        currentPage += 1
        APIService.loadData(for: currentPage, type: getModel) { [weak self] result in
            switch result {
            case .success(let success):
                guard let success else {
                    return
                }
                self?.getModel?.content += success.content
                self?.isFetchingNextPage = false
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func createAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Warning",
            message: "No camera available",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    private func requestAccessToCamera(choosenCell: Int) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] allowed in
            guard let self else {
                return
            }
            if allowed {
                DispatchQueue.main.async {
                    self.present(self.picker, animated: false)
                    self.choosenCell = choosenCell
                }
            } else {
                DispatchQueue.main.async {
                    self.createAccessDeniedAlert()
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getModel?.totalElements ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: MainTableViewCell.self),
            for: indexPath
        ) as? MainTableViewCell else {
            return UITableViewCell()
        }
        guard let getModel else { return cell }
        cell.fill(with: (getModel.content[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            self.requestAccessToCamera(choosenCell: indexPath.row)
        case .restricted:
            self.createAccessDeniedAlert()
        case .denied:
            self.createAccessDeniedAlert()
        case .authorized:
            self.present(self.picker, animated: false)
            self.choosenCell = indexPath.row
        default:
            break
        }
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let getModel else {
            return
        }
        let needsFetch = indexPaths.contains { $0.row > (getModel.content.count) }
        if needsFetch && currentPage <= 6 {
            fetchNextPage()
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        self.picker.dismiss(animated: true)
        
        guard let pickedImage = info[.originalImage] as? UIImage,
              let image = pickedImage.pngData(),
              let getModel
        else {
              return
        }

        let dataToSend = PostModel(
            name: "Saiko Vadim",
            typeId: (getModel.content[choosenCell].id),
            photo: image
        )
        APIService.sendImage(dataToSend)
    }
}
