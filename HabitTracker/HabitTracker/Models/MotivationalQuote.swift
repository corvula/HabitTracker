import Foundation

struct MotivationalQuote {
    let text: String
    let author: String
    
    static let quotes = [
        MotivationalQuote(text: "Успіх - це сума маленьких зусиль, які повторюються день за днем", author: "Роберт Колльєр"),
        MotivationalQuote(text: "Ти сильніший, ніж думаєш", author: ""),
        MotivationalQuote(text: "Кожен день - це новий шанс стати кращою версією себе", author: ""),
        MotivationalQuote(text: "Не лічи дні, зроби так, щоб дні лічилися", author: "Мухаммед Алі"),
        MotivationalQuote(text: "Звички формують характер, характер формує долю", author: ""),
        MotivationalQuote(text: "Мотивація - це те, що допомагає почати. Звичка - це те, що допомагає продовжувати", author: "Джим Рюн"),
        MotivationalQuote(text: "Єдиний спосіб зробити чудову роботу - любити те, що ти робиш", author: "Стів Джобс"),
        MotivationalQuote(text: "Не чекай ідеального моменту. Візьми момент і зроби його ідеальним", author: ""),
        MotivationalQuote(text: "Зміни - це важко спочатку, безладно посередині і прекрасно в кінці", author: "Робін Шарма"),
        MotivationalQuote(text: "21 день створює звичку, 90 днів створює спосіб життя", author: ""),
    ]
    
    static func random() -> MotivationalQuote {
        quotes.randomElement() ?? quotes[0]
    }
}
