//
//  SampleBooks.swift
//  BookFlip
//
//  Original sample stories written for this demo.
//

import SwiftUI

nonisolated extension Book {
    static let samples: [Book] = [.lighthouse, .rooftopGarden]

    static let lighthouse = Book(
        id: "lighthouse",
        title: "Ngọn Hải Đăng Cuối Cùng",
        author: "Truyện mẫu BookFlip",
        synopsis: "Mùa đông cuối cùng của người gác đèn trên hòn đảo nhỏ, và lá thư trôi dạt ba mươi năm.",
        cover: BookCover(
            top: Color(red: 0.11, green: 0.20, blue: 0.33),
            bottom: Color(red: 0.04, green: 0.08, blue: 0.15),
            accent: Color(red: 0.98, green: 0.80, blue: 0.45),
            symbol: "light.beacon.max"
        ),
        chapters: [
            Chapter(title: "Người gác đèn", text: """
            Trên mỏm đá xa nhất của hòn đảo nhỏ, nơi gió biển thổi quanh năm không ngớt, có một ngọn hải đăng sơn trắng đã bạc màu. Người gác đèn tên là ông Tư. Ông sống ở đó đã gần bốn mươi năm, lâu đến mức dân làng chài dưới bến không còn nhớ ngọn đèn ấy từng có ai khác trông coi. Mỗi chiều, khi mặt trời chạm xuống đường chân trời, ông lại chậm rãi leo một trăm mười hai bậc thang xoắn ốc để thắp sáng chiếc đèn lớn trên đỉnh tháp.

            Ông Tư không có vợ con. Bạn đồng hành duy nhất của ông là một con mèo mướp tên Muối, lông xám như màu đá ướt, lúc nào cũng nằm cuộn tròn bên bậu cửa sổ nhìn ra biển. Ông thường nói chuyện với nó như nói với một người bạn già, kể về con nước lên xuống, về những đàn chim di trú bay ngang trời mỗi độ thu sang, về những con tàu đã đi qua vùng biển này trong suốt mấy chục năm ròng.

            Căn phòng nhỏ dưới chân tháp chỉ có một chiếc giường gỗ, một chiếc bàn kê sát cửa sổ và một kệ sách cũ chất đầy những cuốn sổ ghi chép. Mỗi đêm, sau khi kiểm tra ngọn đèn lần cuối, ông Tư lại ngồi xuống bàn, thắp ngọn đèn dầu nhỏ và ghi vào sổ những gì mình thấy trong ngày: hướng gió, màu của nước, số tàu đi ngang qua, và đôi khi là một ý nghĩ chợt đến mà ông không biết kể cùng ai.

            Người trong làng bảo ông lập dị. Họ không hiểu vì sao một người đàn ông lại có thể sống một mình giữa biển suốt ngần ấy năm mà không thấy cô đơn. Nhưng ông Tư chưa bao giờ nghĩ mình cô đơn. Ông có biển, có gió, có con mèo già và có ngọn đèn. Với ông, mỗi luồng sáng quét qua mặt nước là một lời chào gửi tới những người đang lênh đênh ngoài khơi, rằng họ không hề đơn độc.

            Rồi một buổi sáng đầu tháng Mười, chiếc thuyền chở thư từ đất liền ghé đảo sớm hơn thường lệ. Người đưa thư trao cho ông một phong bì dày, đóng dấu của sở hàng hải. Ông Tư đeo kính, đọc chậm từng dòng. Bức thư viết rằng ngọn hải đăng sẽ được thay bằng một hệ thống đèn tự động vào mùa xuân năm sau, và ông sẽ được nghỉ hưu sau bao năm tận tụy.

            Ông gấp lá thư lại, đặt nó dưới chiếc chặn giấy bằng vỏ ốc, rồi ngồi im rất lâu bên cửa sổ. Ngoài kia, biển vẫn xanh như mọi ngày, sóng vẫn vỗ vào ghềnh đá như chưa từng có điều gì thay đổi. Con mèo Muối nhảy lên đùi ông, dụi đầu vào tay ông như muốn hỏi chuyện gì đã xảy ra. Ông xoa đầu nó và khẽ nói: “Còn một mùa đông nữa, Muối ạ. Chúng ta sẽ làm cho nó thật trọn vẹn.”
            """),
            Chapter(title: "Cơn bão tháng Mười", text: """
            Những ngày sau đó, ông Tư làm việc chăm chỉ hơn bao giờ hết. Ông lau từng tấm kính của lồng đèn cho đến khi chúng sáng trong như mặt nước hồ, tra dầu cho bộ máy quay, sơn lại lan can đã han gỉ. Ông biết những việc ấy rồi cũng sẽ không còn ai cần đến, nhưng đôi tay ông đã quen với chúng như quen với nhịp thở của chính mình.

            Vào giữa tháng, trời bắt đầu chuyển. Những đám mây xám nặng trĩu kéo về từ phía đông, gió đổi hướng liên tục và mùi muối trong không khí đặc lại đến mức có thể nếm thấy trên đầu lưỡi. Chiếc đài cũ trên bàn rè rè báo tin một cơn bão lớn đang tiến vào vùng biển. Ông Tư kiểm tra lại máy phát điện dự phòng, xếp sẵn những can dầu cạnh chân cầu thang và buộc chặt mọi cánh cửa.

            Cơn bão ập đến lúc chạng vạng. Mưa quất ngang như những sợi roi bạc, sóng dâng cao trùm qua cả mỏm đá thấp nhất. Cả ngọn tháp rung lên từng hồi theo những cơn gió giật. Muối trốn vào gầm giường, đôi mắt vàng mở to trong bóng tối. Ông Tư leo lên đỉnh tháp, áo mưa ướt sũng, tay bám chặt vào lan can, và đúng lúc ấy, điện trên đảo vụt tắt.

            Trong một khoảnh khắc, cả vùng biển chìm vào màu đen đặc quánh. Ông Tư mò mẫm trong bóng tối, đếm từng bậc thang đi xuống phòng máy. Ông đã làm việc này hàng trăm lần trong những giấc mơ, nhưng chưa bao giờ đôi tay ông run như đêm ấy. Tiếng máy phát điện dự phòng khục khặc vài lần rồi tắt lịm. Ông lau tay, kiên nhẫn giật dây khởi động thêm một lần nữa, rồi thêm một lần nữa.

            Đến lần thứ bảy, cỗ máy cũ rùng mình rồi gầm lên. Ông Tư lại leo lên đỉnh tháp, thở hổn hển, và khi luồng sáng đầu tiên xuyên qua màn mưa, ông nhìn thấy nó: một đốm đèn nhỏ chao đảo giữa những con sóng, cách ghềnh đá ngầm chưa đầy một hải lý. Một con tàu đang lạc hướng, và nó đang tiến thẳng về phía bãi đá.

            Ông bật đèn tín hiệu, nháy liên tục theo mã mà ông đã thuộc lòng từ thời trai trẻ. Ánh sáng quét qua quét lại, vạch một con đường sáng trên mặt biển cuồn cuộn. Đốm đèn nhỏ ngập ngừng, rồi chậm rãi đổi hướng, vòng qua mỏm đá ngầm và biến mất sau màn mưa về phía vịnh kín gió. Ông Tư đứng đó rất lâu, nước mưa chảy dài trên mặt, không biết là mưa hay là nước mắt.
            """),
            Chapter(title: "Bức thư trong chai", text: """
            Sáng hôm sau, biển lặng như chưa từng có cơn bão nào đi qua. Bầu trời trong vắt, những con mòng biển lại chao lượn trên mặt nước lấp lánh. Ông Tư đi dọc bờ đá để kiểm tra những gì cơn bão để lại: vài tấm ván gỗ trôi dạt, một tấm lưới rách, những đám rong biển phủ kín các hốc đá. Muối lon ton theo sau, thỉnh thoảng dừng lại đánh hơi một con cua nhỏ đang vội vã chui vào khe.

            Giữa đống rong rêu, một thứ gì đó lóe sáng dưới nắng. Ông cúi xuống nhặt lên: một chiếc chai thủy tinh màu xanh lục, nút bần còn nguyên, bên trong cuộn tròn một mảnh giấy đã ngả vàng. Ông mang nó về phòng, cẩn thận rút nút và trải mảnh giấy ra trên mặt bàn. Nét chữ nghiêng nghiêng, mềm mại, viết bằng thứ mực tím đã nhạt màu theo năm tháng.

            “Gửi người nào nhặt được lá thư này,” bức thư bắt đầu. “Tôi mười hai tuổi, đang ở trên một con tàu đi qua vùng biển có ngọn hải đăng trắng. Mẹ tôi nói rằng ánh đèn ấy đã giúp bố tôi tìm được đường về nhà trong một đêm bão nhiều năm trước. Tôi viết lá thư này để cảm ơn người đã giữ cho ngọn đèn luôn sáng. Nếu một ngày nào đó tôi lớn lên, tôi cũng muốn trở thành một người giữ ánh sáng cho người khác.”

            Cuối thư không có tên, chỉ có một hình vẽ nhỏ: một ngọn hải đăng với những tia sáng tỏa ra như cánh hoa. Ông Tư đọc đi đọc lại bức thư ấy đến lần thứ mười. Ông lật giở những cuốn sổ cũ, tìm lại những đêm bão của ba mươi năm trước. Có một dòng ghi chép viết vội: “Đêm mười bốn, tàu cá số hiệu không rõ suýt mắc cạn, đã nháy đèn dẫn đường, tàu an toàn.”

            Ông không biết lá thư đã trôi dạt bao lâu trên biển, cũng không biết cô bé năm ấy giờ đang ở nơi nào. Nhưng lần đầu tiên sau nhiều tháng, ông thấy lòng mình nhẹ hẳn đi. Những đêm thức trắng, những bậc thang đếm mãi không hết, những tấm kính lau đi lau lại, hóa ra chưa bao giờ là vô ích. Ở đâu đó, có những con người đã về được đến nhà nhờ một ánh đèn nhỏ.

            Ông kẹp bức thư vào giữa cuốn sổ mới nhất, ngay sau trang ghi chép về đêm bão vừa rồi. Rồi ông viết thêm một dòng bên dưới, nắn nót hơn thường lệ: “Đêm qua có một con tàu lạc hướng. Đèn vẫn sáng. Tàu đã về bến an toàn.” Muối nằm trên bậu cửa sổ, nheo mắt nhìn ông như thể nó hiểu hết.
            """),
            Chapter(title: "Con tàu không tên", text: """
            Một tuần sau cơn bão, một chiếc tàu lạ cập vào bến nhỏ của đảo. Thân tàu sơn xanh đã tróc lở nhiều chỗ, mũi tàu không có tên, chỉ có một hình ngọn hải đăng vẽ tay đã mờ. Từ trên tàu bước xuống là một người phụ nữ trạc ngoài bốn mươi, mái tóc cắt ngắn, khoác chiếc áo gió màu cam của đội cứu hộ hàng hải. Bà hỏi thăm đường lên ngọn hải đăng, rồi một mình leo con dốc đá quanh co.

            Ông Tư đang tưới mấy chậu rau thơm trước cửa thì thấy bà đến. Người phụ nữ dừng lại, nhìn ngọn tháp trắng rất lâu, rồi mới quay sang ông. “Đêm hôm trước, chính tôi là người lái con tàu ấy,” bà nói. “Máy định vị hỏng, đài liên lạc mất sóng. Nếu không có ánh đèn của ông, có lẽ tôi và hai người thủy thủ đã nằm lại dưới đáy biển rồi.”

            Ông Tư mời bà vào nhà, pha một ấm trà gừng. Họ ngồi bên chiếc bàn kê sát cửa sổ, nói chuyện về biển, về những cơn bão, về những con tàu. Khi bà kể rằng thuở nhỏ mình từng thả một chiếc chai xuống biển, ông Tư lặng người đi. Ông đứng dậy, lấy cuốn sổ trên kệ và mở ra trang có kẹp lá thư. Người phụ nữ nhìn nét chữ tím quen thuộc, đưa tay lên che miệng.

            “Ba mươi năm,” bà thì thầm. “Tôi đã nghĩ nó chìm từ lâu rồi.” Bà kể rằng sau lần đi biển năm ấy, bà quyết định theo nghề cứu hộ. Bà đã kéo hàng chục người ra khỏi những con sóng dữ, đã thức trắng không biết bao nhiêu đêm bên chiếc đài liên lạc. Con tàu của bà không có tên, vì bà muốn nó chỉ mang một hình ảnh duy nhất: ngọn hải đăng đã dẫn bố bà về nhà.

            Họ ngồi với nhau đến khi nắng chiều nhuộm vàng cả căn phòng. Trước khi về, bà nhìn quanh những kệ sổ, những tấm kính lồng đèn sáng bóng, rồi hỏi ông sẽ làm gì khi ngọn hải đăng chuyển sang chế độ tự động. Ông Tư mỉm cười, lắc đầu: “Tôi cũng chưa biết nữa. Có lẽ tôi sẽ học cách ngủ trọn một đêm.” Cả hai cùng bật cười, tiếng cười vang lên giữa căn phòng nhỏ.
            """),
            Chapter(title: "Ánh sáng trở về", text: """
            Mùa đông năm ấy trôi qua êm đềm hơn ông tưởng. Người phụ nữ thường ghé đảo mỗi khi tàu của bà đi ngang qua, mang theo khi thì túi cam, khi thì vài cuốn sách mới. Bà ngồi nghe ông kể về từng con nước, từng hướng gió, chép lại những điều ông biết vào một cuốn sổ riêng. Ông nhận ra mình đang trao lại cho bà những thứ mà không một hệ thống tự động nào có thể ghi nhớ.

            Mùa xuân đến cùng với một đoàn kỹ sư từ đất liền. Họ lắp những tấm pin mặt trời trên mái nhà, thay bộ máy quay cũ bằng một chiếc hộp kim loại nhỏ nhấp nháy đèn xanh. Ông Tư đứng xem họ làm việc, tay khoanh trước ngực, không nói gì nhiều. Khi người kỹ sư trưởng bấm nút khởi động, ngọn đèn tự sáng lên đúng giờ, không cần ai leo lên một trăm mười hai bậc thang.

            Đêm cuối cùng trên đảo, ông Tư vẫn leo lên đỉnh tháp như một thói quen. Ông đứng nhìn luồng sáng quét qua mặt biển, đều đặn và chính xác như chưa từng có ai trông nom. Muối ngồi bên chân ông, cái đuôi xám quấn quanh mắt cá chân. Ông nghĩ về những con tàu, về lá thư trong chai, về người phụ nữ với chiếc áo gió màu cam. Ánh sáng, ông chợt hiểu, chưa bao giờ thuộc về ngọn đèn.

            Sáng hôm sau, con tàu không tên cập bến. Người phụ nữ giúp ông khuân những thùng sổ ghi chép xuống tàu. Bà đã xin được cho ông một chân hướng dẫn tại trạm cứu hộ trên đất liền, nơi những người thủy thủ trẻ cần học cách đọc gió và nghe biển. Ông Tư ngoái nhìn ngọn tháp trắng lần cuối, rồi bế Muối bước lên boong tàu.

            Con tàu rời đảo khi mặt trời vừa lên khỏi mặt nước. Phía sau họ, ngọn hải đăng nhỏ dần rồi chỉ còn là một chấm trắng nơi đường chân trời. Ông Tư mở cuốn sổ mới, viết dòng đầu tiên bằng nét chữ chậm rãi quen thuộc: “Ngày đầu tiên. Gió nhẹ hướng nam. Biển xanh. Đèn vẫn sáng, và lần này có người khác giữ nó cùng tôi.”
            """),
        ]
    )

    static let rooftopGarden = Book(
        id: "rooftop-garden",
        title: "Khu Vườn Trên Mái",
        author: "Truyện mẫu BookFlip",
        synopsis: "Một gói hạt hướng dương, một sân thượng bỏ hoang và những người hàng xóm chưa từng quen.",
        cover: BookCover(
            top: Color(red: 0.36, green: 0.52, blue: 0.32),
            bottom: Color(red: 0.16, green: 0.29, blue: 0.18),
            accent: Color(red: 1.00, green: 0.84, blue: 0.30),
            symbol: "sun.max"
        ),
        chapters: [
            Chapter(title: "Hạt giống đầu tiên", text: """
            Căn hộ của Linh nằm trên tầng cao nhất của một khu tập thể cũ giữa lòng thành phố. Từ cửa sổ nhìn ra chỉ thấy những mái tôn chen chúc, những sợi dây điện chằng chịt và một khoảng trời hẹp màu xám nhạt. Cô chuyển đến đây vào cuối mùa đông, mang theo hai va li quần áo, một thùng sách và một gói hạt giống hoa hướng dương mà bà ngoại gửi theo trước lúc cô lên đường.

            Phía trên căn hộ là một sân thượng bỏ hoang. Gạch lát đã vỡ nhiều chỗ, rêu mọc xanh các góc tường, vài chiếc chậu sành cũ nằm lăn lóc bên bể nước. Lần đầu tiên leo lên đó, Linh đứng giữa gió và nghe tiếng thành phố vọng lên từ bên dưới: tiếng còi xe, tiếng rao hàng, tiếng một ai đó đang tập đàn ở căn hộ bên cạnh. Cô bỗng nghĩ, nơi này cần một chút màu xanh.

            Cuối tuần ấy, cô mua mấy bao đất, xin thêm vài chiếc thùng xốp ở chợ đầu ngõ và bắt đầu dọn dẹp. Cô nhổ cỏ, quét rêu, kê lại những chiếc chậu sành cho ngay ngắn. Gói hạt giống của bà được gieo xuống những luống đất nhỏ, mỗi hạt cách nhau một gang tay, đúng như lời bà dặn trong mẩu giấy viết tay kẹp trong gói.

            Những ngày sau đó, sáng nào trước khi đi làm Linh cũng leo lên sân thượng tưới nước. Đất vẫn nâu và im lìm, không có dấu hiệu gì của sự sống. Đôi khi cô tự hỏi liệu những hạt giống ấy có quá cũ, hay gió thành phố có quá khắc nghiệt với chúng. Nhưng cô vẫn tưới, đều đặn như một lời hứa nhỏ với chính mình.
            """),
            Chapter(title: "Những người hàng xóm", text: """
            Một buổi sáng tháng Ba, Linh phát hiện ra những mầm xanh đầu tiên nhú lên khỏi mặt đất, bé xíu và cong cong như những dấu hỏi. Cô ngồi xổm xuống, nhìn chúng rất lâu, rồi bật cười một mình giữa sân thượng vắng. Đúng lúc ấy, cánh cửa sắt kẽo kẹt mở ra. Một cụ ông tóc bạc trắng, tay cầm chiếc lồng chim, ngạc nhiên nhìn những thùng xốp xếp thành hàng.

            Cụ là ông Bảy ở tầng dưới, sáng nào cũng mang chú chim chào mào lên sân thượng phơi nắng. Thấy khu vườn nhỏ, cụ gật gù khen rồi chỉ cho Linh cách làm giàn cho đậu leo, cách trộn vỏ trứng vào đất để cây cứng cáp hơn. Hôm sau, cụ mang lên một chậu húng quế. Hôm sau nữa, cô bé con nhà bên cạnh rụt rè xin được gieo vài hạt cà chua.

            Cứ thế, khu vườn lớn dần lên cùng những người hàng xóm. Chị Hạnh bán xôi đầu ngõ góp mấy nhánh sả. Anh sinh viên tập đàn mang lên một chiếc ghế gỗ tự đóng. Có người treo thêm dây đèn nhỏ dọc lan can, có người đặt một chiếc bàn con để mọi người ngồi uống trà mỗi tối. Sân thượng bỏ hoang ngày nào giờ trở thành nơi cả khu tập thể hẹn nhau sau một ngày dài.

            Linh nhận ra mình đã không còn cảm thấy lạ lẫm với thành phố này nữa. Cô biết tên từng người, biết ai thích trà đặc, ai sợ sâu, ai hay kể chuyện cười nhạt nhưng vẫn khiến cả nhóm phá lên cười. Những buổi tối trên sân thượng, giữa mùi húng quế và tiếng đàn ghi ta lạc nhịp, cô thấy lòng mình bình yên như những ngày còn ở quê với bà.
            """),
            Chapter(title: "Mùa hướng dương", text: """
            Đến đầu hè, những cây hướng dương đã cao quá đầu người. Những nụ hoa xanh căng tròn, ngày một nặng dần, quay về phía mặt trời mỗi sáng. Cả khu tập thể háo hức chờ đợi như chờ một ngày hội. Cô bé nhà bên đếm từng nụ hoa mỗi chiều đi học về, rồi báo cáo kết quả với mọi người bằng giọng nghiêm trang như một nhà khoa học nhỏ.

            Rồi một sáng tháng Sáu, Linh leo lên sân thượng và đứng sững lại. Cả khu vườn rực lên một màu vàng óng. Hàng chục bông hướng dương cùng nở một lúc, những cánh hoa xòe rộng như những chiếc đĩa nắng giữa nền trời xanh. Từ những ô cửa sổ xung quanh, người ta ló đầu ra nhìn, có người còn giơ điện thoại lên chụp ảnh khu vườn trên mái nhỏ bé ấy.

            Tối hôm đó, cả khu tập thể tụ họp trên sân thượng. Ông Bảy mang lên một ấm trà ngon, chị Hạnh mang lên một mâm xôi gấc đỏ au, anh sinh viên đàn một bài hát mà ai cũng thuộc. Linh gọi điện cho bà ngoại, xoay màn hình cho bà nhìn thấy những bông hoa vàng rực dưới ánh đèn. Bà cười móm mém, bảo rằng hạt giống tốt thì ở đâu cũng nở được, miễn là có người chịu tưới.

            Cuối mùa, Linh cẩn thận thu những hạt hướng dương già, phơi khô rồi chia thành nhiều gói nhỏ. Cô viết lên mỗi gói một mẩu giấy, giống hệt mẩu giấy bà từng viết cho cô: gieo cách nhau một gang tay, tưới mỗi sáng, và đừng bao giờ mất kiên nhẫn. Rồi cô đặt chúng vào một chiếc giỏ mây cạnh cửa sân thượng, để bất kỳ ai đi qua cũng có thể mang về một khu vườn của riêng mình.
            """),
        ]
    )
}
