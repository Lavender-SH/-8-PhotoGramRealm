//
//  RealmModel.swift
//  PhotoGramRealm
//
//  Created by 이승현 on 2023/09/04.
//

import Foundation
import RealmSwift

//⭐️⭐️⭐️
class DiaryTable: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var diaryTitle: String //일기 제목(필수)
    @Persisted var diaryDate: Date //일기 등록 날짜(필수)
    @Persisted var diaryContents: String? //일기 내용 (옵션)
    @Persisted var diaryPhotoURL: String? //일기 사진 URL(옵션)
    @Persisted var diaryLike: Bool //즐겨찾기 기능(필수)


    convenience init(diaryTitle: String, diaryDate: Date, diaryContents: String?, diaryPhotoURL: String?, diaryLike: Bool) {
        self.init()
        
        self.diaryTitle = diaryTitle
        self.diaryDate = diaryDate
        self.diaryContents = diaryContents
        self.diaryPhotoURL = diaryPhotoURL
        self.diaryLike = true
    }


}

