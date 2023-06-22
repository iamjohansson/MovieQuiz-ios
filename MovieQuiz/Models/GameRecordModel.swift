import Foundation

struct GameRecord: Codable, Comparable {
    //кол-во правильных ответов
    let correct: Int
    //кол-во вопросов квиза
    let total: Int
    //дата завершения
    let date: Date

    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }

}
