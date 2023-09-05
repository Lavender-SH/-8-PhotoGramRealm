//
//  HomeViewController.swift
//  PhotoGramRealm
//
//  Created by jack on 2023/09/03.
//

import UIKit
import SnapKit
import RealmSwift

class HomeViewController: BaseViewController {
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        view.register(PhotoListTableViewCell.self, forCellReuseIdentifier: PhotoListTableViewCell.reuseIdentifier)
        return view
    }()
    
    //⭐️⭐️⭐️
    var tasks: Results<DiaryTable>!
    let realm = try! Realm()
    
    //⭐️⭐️⭐️
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Realm Read
        tableView.backgroundColor = .black
        tasks = realm.objects(DiaryTable.self).sorted(byKeyPath: "diaryDate", ascending: true)  //전체를 읽기

        print(realm.configuration.fileURL) // 실제 데이터 저장 파일 경로
        // viewDidLoad에서 한번만 데이터를 담고 viewWillAppear에서 reload데이터를 하면 갱신이 안되는게 당연한 것 같지만 realm 특성에 따라 데이터가 추가되면 알아서 실시간으로 update가 되는 특성을 가지고 있다.
        
    }
    //⭐️⭐️⭐️
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    
    
    override func configure() {
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
        
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        let backupButton = UIBarButtonItem(title: "백업", style: .plain, target: self, action: #selector(backupButtonClicked))
        navigationItem.leftBarButtonItems = [sortButton, filterButton, backupButton]
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func plusButtonClicked() {
        navigationController?.pushViewController(AddViewController(), animated: true)
    }
    
    @objc func backupButtonClicked() {
        
    }
    
    
    @objc func sortButtonClicked() {
        
    }
    
    @objc func filterButtonClicked() {
        // filter
        // realm filter는 제약이 조금 많다.
        // 특수한 케이스 필터가 많이 없어서 복잡한 filter가 필요하다면 realm을 써야되는지 한번 다시 생각해볼 것.
       
        let result = realm.objects(DiaryTable.self).where {
            //1. 대소문자 구별 없음 - caseInsensitive
            
            //$0.diaryTitle.contains("제목", options: .caseInsensitive)
            
            //2. Bool
            //$0.diaryLike == true
            
            //3. 사진이 있는 데이터만 불러오기 (diaryPhoto의 nil 여부 판단) / 2개 같이 쓰는 법
            ($0.diaryPhotoURL != nil) //&& ($0.diaryLike == true)
        }
            
        tasks = result
        tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //⭐️⭐️⭐️
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoListTableViewCell.reuseIdentifier) as? PhotoListTableViewCell else { return UITableViewCell() }
        
        let data = tasks[indexPath.row]
        
        cell.titleLabel.text = data.diaryTitle
        cell.contentLabel.text = data.diaryContents
        cell.dateLabel.text = "\(data.diaryDate)"
        
        cell.diaryImageView.image = loadImageFromDocument(fileName: "jack_\(data._id).jpg")
        
        
        
        let url = URL(string: data.diaryPhotoURL ?? "")
        // realm DB에서 데이터를 가져와야하는데 비동기 구문에 넣으면 에러 남
        //string -> url -> Data -> UIImage
        //1. 셀 서버통신 용량이 크다면 로드가 오래걸릴 수 있음.
        //2. 이미지를 미리 UIImage 형식으로 반환하고, 셀에세서 UIImage를 바로 보여주자!
        //=> 재사용 메커니즘을 효율적으로 사용하지 못할 수도 있고, UIImage 배열 구성 자체가 오래 걸릴 수 있음
        // => 사용자가 안볼수도 있는 이미지까지 미리 로드해버리면, 시간이 오래걸림.
        DispatchQueue.global().async {
            if let url = url, let data = try? Data(contentsOf: url) {
                //string -> url -> Data -> UIImage
                DispatchQueue.main.async {
                    cell.diaryImageView.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Realm Delete
//        let data = tasks[indexPath.row]
//
////        try! realm.write {
////            realm.delete(data)
////        }
//
//        removeImageFromDocument(fileName: "jack_\(data._id).jpg")
//
//        try! realm.write {
//            realm.delete(data)
//        }
//
//        tableView.reloadData()
        //⭐️⭐️⭐️
        let vc = DetailViewController()
        vc.data = tasks[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let like = UIContextualAction(style: .normal, title: "좋아여") { action, view, completionHandler in
            print("좋아요 선택됨77")
        }
        
        like.backgroundColor = .orange
        like.image = tasks[indexPath.row].diaryLike ? UIImage(systemName: "star.fill") : UIImage(systemName: "star") //좋아요 눌렀냐 안눌렸냐에 따라
        
        let sample = UIContextualAction(style: .normal, title: "좋아여") { action, view, completionHandler in   //title: nil로 하면 제목없이 심플하게 나옴
            print("좋아요 선택됨88")
        }
        
        sample.backgroundColor = .orange
        sample.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [like, sample])
    }
}






