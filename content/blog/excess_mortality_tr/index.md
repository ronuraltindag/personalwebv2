---
draft: false
title: "Koronavirüs vefat sayıları ne anlatıyor?"
links:
- icon: github
  icon_pack: fab
  name: Veri 
  url: https://github.com/ronuraltindag/excess_mortality
author: Onur Altındağ 
date: '2020-05-03'
summary: "Hepimizin takip ettiği ve Sağlık Bakanlığı tarafından açıklanan koronovirüs bağlantılı ölüm sayıları, tıbbi testlerle virüsü taşıdığı teyit edilmiş hastaların vefatlarını yansıtıyor. Türkiye de diğer ülkeler gibi tanı konmadan vefat etmiş hastaları bu istatistiklere dahil etmiyor. Bu nedenle, direkt ya da dolaylı yoldan koronavirüs nedeniyle ölen hasta sayısı, beyan edilen rakamların üstünde." 


---

**Note:** Click [here](/blog/excess_mortality/) for the English version of this post. 

Hepimizin takip ettiği ve Sağlık Bakanlığı tarafından açıklanan koronovirüs bağlantılı ölüm sayıları, tıbbi testlerle virüsü taşıdığı teyit edilmiş hastaların vefatlarını yansıtıyor. Türkiye de diğer ülkeler gibi tanı konmadan vefat etmiş hastaları bu istatistiklere dahil etmiyor. Bu nedenle, direkt ya da dolaylı yoldan koronavirüs nedeniyle ölen hasta sayısı, beyan edilen rakamların üstünde.

Vefat sayılarındaki az bildirimin derecesi, bir ülkenin kurumsal kapasitesine ve salgın tarafından ne ölçüde etkilendiği ile yakından ilgili. Genel olarak, kalkınmakta olan ülkeler ve salgının yoğun yaşandığı yerlerde, açıklanan sayıların gerçekleşenden daha uzak olacağını öngörebiliriz. Veri girişlerindeki ölçüm hatalarına ek olarak, salgının yoğun yaşandığı yerlerde virüs, hastane ve yoğun bakım talebini en üst noktalara çıkardığı için virüsten bağımsız gerçekleşen ölümlerin artması da  mümkün. Diğer yandan, hayatın normal akışı durduğu için trafik kazalarının azalması, insanların daha sakin bir hayat tarzına geçmesi ve yaşlıların bakım kalitesinin artması gibi nedenlerle, virüsten kaynaklanmayan ölümlerin sayılarında düşüş görülmesi de olası.<sup>1</sup>

COVID-19 bağlantılı ölümlerle ilgili az bildirimin miktarı, ülkeden ülkeye büyük farklılık gösteriyor. The Economist dergisi, yaptığı bir [çalışmada](https://www.economist.com/graphic-detail/2020/04/16/tracking-covid-19-excess-deaths-across-countries) İtalya ve Hollanda’da beklenenden fazla gerçekleşen ölüm sayısının (excess mortality) resmi olarak açıklanan COVID-19 nedenli ölüm sayısının **iki** katından fazla olduğunu öngörüyor. İspanya, İngiltere ve ABD’de az bildirim daha düşük olsa da virüs bağlantılı ölümlerin açıklanan sayıların **%10** ila **%60** üstünde.

## İstanbul ve Türkiye'deki COVID-19 nedenli ölümler 

Türk Tabipler Birliği, Turkiye’deki raporlamada klinik bulguları koronavirüsü işaret eden ama PCR testi negatif çıkan hastaların vefatı halinde, vefat nedeninin koronavirüs olarak kayıt edilmediğini  [açıkladı](http://www.cumhuriyet.com.tr/haber/ttb-saglik-bakanligi-kovid-19-olumlerini-dunya-saglik-orgutu-kodlarina-gore-raporlamiyor-1731938). Diğer bir deyişle, Türkiye’de de az bildirim var, ancak miktarını bilmiyoruz. Ancak  açıklanan sayıların gerçekleşenin ne kadar altında olduğunu  tahmin etmek kamu sağlığı açısından elzem. Bu çalışmada devlet tarafından yayınlanan halka açık veriler ışığında bir tahmin yapmaya çalışacağım.

Aşağıdaki ilk grafik, 2016-2020 yılları arasında Ocak-Nisan ayları arasında gerçekleşen vefat sayılarını göstermekte. İstanbul Büyükşehir Belediyesi tarafından derlenen bu sayılar, herhangi bir nedenle vefat etmiş ve İstanbul’da defnedilmiş ölümleri kapsamakta.<sup>2</sup>  **Kırmızı** renkle gösterdiğim 2020 senesinde, Mart başında başlayan güçlü bir artış söz konusu. Bu anormal değişimin büyüklüğünü ölçmek için basit bir regresyon ile 2020 senesi Mart başından bugüne kadar beklenen ölüm rakamlarını belirleyip beklenenden fazla gerçekleşen ölüm sayısını tahmin etmek mümkün. 





![](/static/images/posts/excess_mortality/istanbul1-1.png)




İkinci grafikteki **kırmızı**  çizgi 2020 yılı için beklenenden fazla gerçekleşen ölüm sayılarını gösteriyor. Basit bir tahmin ile 12 Mart-11 Nisan tarihleri arasında İstanbul’daki vefat sayılarının normalde gerçekleşmesi beklenenden 2,158 kişi [%95 güven aralığı: 1,976-2,340] fazla olduğunu söylemek mümkün. Sağlık Bakanlığı koronavirüs nedeniyle gerçekleşen ölümleri il bazında açıklamıyor. Bu nedenle tam bir karşılaştırma mümkün değil ama Sağlık Bakanlığı’nın şu ana kadar tüm Türkiye için açıkladığı rakamlara bakmak az bildirimin boyutları konusunda fikir verebilir. Sağlık Bakanlığı’nın açıkladığı ve tüm Türkiye’de koronavirüs nedenli ölümleri kapsayan günlük rakamları **siyah** çizgi ile gösteriyorum. Resmi rakamlara göre 12 Mart-11 Nisan tarihleri arasında tüm ülkede 1,006 kişiyi koronavirüs nedeniyle kaybettik. Aynı zaman diliminde yalnız İstanbul’da hesapladığım beklenenin üstündeki vefat sayısı bu rakamın iki katı. Bu bariz farkı açıklayabilecek akla gelen birkaç hipotez/senaryo var:



- Test kapasitesi yetersizliği ya da test sonucundaki belirsizlikler nedeniyle klinik olarak koronavirüs nedeniyle ölen hastalar başka bir ICD10 koduyla kaydediliyor (zatürre, bulaşıcı hastalık, vb.) ve bu resmi istatistiklere yansımıyor.

- İstanbul’da vefat eden ve normal şartlarda memleketine gönderilen cenazeler şehirlerarası seyahat yasakları ve sokağa çıkma kısıtlamaları ve isteksizliği gibi nedenlerle İstanbul’da toprağa veriliyor.

- İstanbul’daki yoğun bakım ve hastane kapasiteleri koronavirüs nedeniyle baskı altında olduğu için diğer hastalıklar sonucunda ölme riski bu süreçte hızlandı. Hastane kapasitesinde problem olmasa bile artan tedbir ve korku nedeniyle hastane talebi düştü. 

İkinci grafikle ilgili başka bir çarpıcı nokta ise İstanbul’da gözlenen normalin üstündeki ölüm artışının Mart başından itibaren gözleniyor olması. Sağlık Bakanlığı’nın ilk koronavirus ölüm açıklaması, Mart ortasına denk geliyor.    

![](/static/images/posts/excess_mortality/istanbul2-1.png)

## Diğer şehirler 

Benzer bir analizi veri erişiminin mümkün olduğu dokuz il için daha gerçekleştirmek mümkün. Bu illerin hiçbirinde İstanbul’daki kadar belirgin bir değişim söz konusu değil. Belki Bursa ve Sakarya’da beklenenin biraz üzerinde ölüm gözlemlense de diğer iller daha önceki yılları takip ediyor. İstanbul’un bu illerden neden bu ölçüde ayrıldığı önemli bir soru ama bu soruya kamuya açık verilerle cevap verebileceğimizi sanmıyorum. Sağlık Bakanlığı'nın açıkladığı verilerin ne anlama geldiğini  daha şeffaf bir şekilde anlatması gerekiyor. 

![](/static/images/posts/excess_mortality/bursa-1.png)
![](/static/images/posts/excess_mortality/denizli-1.png)
![](/static/images/posts/excess_mortality/diyarbakir-1.png)
![](/static/images/posts/excess_mortality/erzurum-1.png)
![](/static/images/posts/excess_mortality/kocaeli-1.png)

![](/static/images/posts/excess_mortality/konya-1.png)

![](/static/images/posts/excess_mortality/malatya-1.png)

![](/static/images/posts/excess_mortality/maras-1.png)

![](/static/images/posts/excess_mortality/sakarya-1.png)

------

<sup>1</sup> Ekonomik durgunluk ve ölüm oranları arasındaki ilişkiyle ilgilenen çalışmaları  özetleyen bir yazı [burada](https://voxeu.org/article/economic-crises-and-mortality).

<sup>2</sup> Ham veriye [buradan](https://www.turkiye.gov.tr/istanbul-buyuksehir-belediyesi-vefat-sorgulama) ulaşmak mümkün. Raporlanan rakamlar aile kabristanına defnedilenleri kapsamamakta.

