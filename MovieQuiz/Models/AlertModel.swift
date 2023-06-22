import UIKit
// новая модель для алерта
struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    let completion: (() -> Void)
}
