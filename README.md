# **# Final-Case-COBOL-Bootcamp**
` `Patika.dev &amp; Akbank is a draft version of the work I developed at the end of COBOL Bootcamp.

## **Proje Tanıtım**
**ANA PROGRAM           = 'REALIDX.CBL'**
**ALT PROGRAM           = 'SUBPROGR.CBL'**
**ANA PROGRAM DERLEYİCİ = 'JREALIDX.JCL'**

Öncelikle bu projenin çalıştırılabilmesi için sırasıyla aşağıdaki adımlara uymamız gerek:

1) **'ZCREATIN.JCL'** dosyamızı submit ederek **'QSAM.INPUT'** isimli dosyayı oluşturmamız gerekiyor.
1) **'Z2PREVSA.JCL'** dosyamızı submit ederek **'QSAM.BB'** isimli dosyayı oluşturmamız gerek.

Bu iki JCL'in içine bakarsanız oluşan **QSAM.INPUT** ve **QSAM.BB** dosyalarımızın datalarını 'SORTIN   DD \*' bölümünde göreceksiniz. Bu kısımdaki veriler oluşturduğumuz iki dosyanın içindeki verilerdir. Fakat QSAM.BB dosyasını sadece bir araç olarak oluşturduk. Çünkü bu **QSAM.BB** dosyasının verilerini okuyarak şimdi de bir **VSAM.AA** dosyası oluşturacağız. Bu **VSAM.AA** dosyası **QSAM.BB** dosyamızdaki aynı verilere sahip olmuş olacak. Bu adımda da VSAM dosyamızı oluşturalım.

3) **'DELDEF01.JCL'** dosyamızı submit ederek **'VSAM.AA'** isimli dosyayı oluşturuyoruz.

**DELDEF01.JCL** dosyasında **VSAM.AA** dosyamız oluşturulurken **QSAM.BB** dosyamızı sildik. Ona ihtiyacımız yok.
Şimdi bakarsak elimizde bir **'VSAM.AA'**, bir de **'QSAM.INPUT'** isminde iki dosyamız var.
Artık projemizi çalıştırabiliriz, fakat çalıştırmadan önce amacımıza bakalım.

### **Projedeki Amaç :**
**QSAM.INPUT** dosyamızdaki satiri okuyup alt programımıza göndermemiz ile birlikte alt programımız bu satirin içinde yer alan ilk harfe göre **'VSAM.AA'** dosyamıza hangi işlemin(fonksiyonun) uygulanacağına karar vererek o işlemi uygulayacak.

Örneğin INPUT'tan okudugumuz ilk deger 'W10001672' olsun. Bu değerin ilk karakteri 'W' olduğu icin alt programımızda açtığımız VSAM dosyamızda '100001672' okuduğumuz bu degere sahip bir kayıt yoksa bu kaydı (W)WRITE etmeyi sağlayacağız. O halde WRITE için bir fonksiyon yazıp bu işlemi orada gercekleştirecegiz. İşlem gerçekleştirilip VSAM dosyamıza bu kaydı ekledikten sonra ise, bu işlemin basarili olup olmadığını ana programımızdan alt programımıza gönderdiğimiz LINKAGE SECTION bölümündeki değişkenlerimize ekleyeceğiz.

Değişkenler artık dolu olduğuna göre alt program ana programa döndüğünde değişen bu değişkenlerimizi OUTPUT olarak açtığımız yeni dosyamıza yazdıracağız. Sonuç olarak OUTPUT dosyamızda işlemlerin başarılı olup olmadığı, başarılı olduysa eski halinin nasıl gözüktüğü ve yeni halinin nasıl gözüktüğü gibi bilgileri yazdıracağız. 
Diğer işlemlerden farklı olarak eğer (R)READ işlemi yaptıysak o zaman VSAM dosyamızdan okuduğumuz bu satırın icerigini İsim Soyisim, Dogum Tarihi(Gregorian olarak), Bütçe(Dolar olarak) şeklinde yazdıracağız.
---
## **Proje İçi Detaylı Not**
#### **DELDEF01.JCL
![alt text](https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/deldef01-1.png?raw=true)
![alt text](https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/deldef01-2.png?raw=true)
#### **JREALIDX.JCL
![alt text](https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/jrealidx-1.png?raw=true)
![alt text](https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/jrealidx-2.png?raw=true)
#### **Z2PREVSA.JCL
![alt text](https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/z2prevsa1.png?raw=true)
![alt text](https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/z2prevsa2.png?raw=true)
