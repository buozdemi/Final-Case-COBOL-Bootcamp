# **Final-Case-COBOL-Bootcamp**
↳ Patika.dev & Akbank işbirliği ile gerçekleştirilen COBOL Bootcamp'i sonunda geliştirmiş olduğum projenin son versiyonudur.

### Teşekkürler

Bu bootcamp'i sağlayan tüm AKBANK ve PATIKA.DEV ailesine, [MEHMET AYDIN](https://www.linkedin.com/in/mehmet-aydin-57088a16/) hocamıza, müthiş desteklerinden dolayı [YUNUS TEYMUR](https://www.linkedin.com/in/yunusteymur/)'a çok teşekkürler.

---

## **Proje Tanıtım**

**ANA PROGRAM = 'REALIDX.CBL'**

**ALT PROGRAM = 'SUBPROGR.CBL'**

**ANA PROGRAM DERLEYİCİ = 'JREALIDX.JCL'**

► NOT1 : JREALIDX.JCL programının derleme işlemi 30-35 saniye sürmektedir.

► NOT2 : Projeyi her çalıştırışınızda mutlaka önce DELDEF01.JCL'ini çalıştırınız. Çünkü proje çalıştığında VSAM dosyasındaki veriler değiştirildiği için verileri eski haline getirmeden ikinci kez SUBMIT JOB yaparsanız, veriler 2. kez değiştirilmeye çalışılacak ve farklı sonuçlar görmenize neden olacaktır.

---

Öncelikle bu projenin çalıştırılabilmesi için sırasıyla aşağıdaki adımlara uymamız gerek:

1) **'ZCREATIN.JCL'** dosyamızı submit ederek **'QSAM.INPUT'** isimli dosyayı oluşturmamız gerekiyor.
1) **'Z2PREVSA.JCL'** dosyamızı submit ederek **'QSAM.BB'** isimli dosyayı oluşturmamız gerek.

Bu iki JCL'in içine bakarsanız oluşan **QSAM.INPUT** ve **QSAM.BB** dosyalarımızın datalarını 'SORTIN   DD \*' bölümünde göreceksiniz. Bu kısımdaki veriler oluşturduğumuz iki dosyanın içindeki verilerdir. Fakat QSAM.BB dosyasını sadece bir araç olarak oluşturduk. Çünkü bu **QSAM.BB** dosyasının verilerini okuyarak şimdi de bir **VSAM.AA** dosyası oluşturacağız. Bu **VSAM.AA** dosyası **QSAM.BB** dosyamızdaki aynı verilere sahip olmuş olacak. 

Bu adımda da VSAM dosyamızı oluşturalım:

3) **'DELDEF01.JCL'** dosyamızı submit ederek **'VSAM.AA'** isimli dosyayı oluşturuyoruz.

**DELDEF01.JCL** dosyasında **VSAM.AA** dosyamız oluşturulurken **QSAM.BB** dosyamızı sildik. Ona ihtiyacımız yok.
Şimdi bakarsak elimizde bir **'VSAM.AA'**, bir de **'QSAM.INPUT'** isminde iki dosyamız var.
Artık projemizi çalıştırabiliriz, fakat çalıştırmadan önce amacımıza bakalım.

---

## **Proje Amacı**
**QSAM.INPUT** dosyamızdaki satiri okuyup alt programımıza göndermemiz ile birlikte alt programımız bu satirin içinde yer alan ilk harfe göre **'VSAM.AA'** dosyamıza hangi işlemin(fonksiyonun) uygulanacağına karar vererek o işlemi uygulayacak.

Örneğin INPUT'tan okudugumuz ilk deger 'W10001672' olsun. Bu değerin ilk karakteri 'W' olduğu icin alt programımızda açtığımız VSAM dosyamızda '100001672' okuduğumuz bu degere sahip bir kayıt yoksa bu kaydı (W)WRITE etmeyi sağlayacağız. O halde WRITE için bir fonksiyon yazıp bu işlemi orada gercekleştirecegiz. İşlem gerçekleştirilip VSAM dosyamıza bu kaydı ekledikten sonra ise, bu işlemin basarili olup olmadığını ana programımızdan alt programımıza gönderdiğimiz LINKAGE SECTION bölümündeki değişkenlerimize ekleyeceğiz.

Değişkenler artık dolu olduğuna göre alt program ana programa döndüğünde değişen bu değişkenlerimizi OUTPUT olarak açtığımız yeni dosyamıza yazdıracağız. Sonuç olarak OUTPUT dosyamızda işlemlerin başarılı olup olmadığı, başarılı olduysa eski halinin nasıl gözüktüğü ve yeni halinin nasıl gözüktüğü gibi bilgileri yazdıracağız. 
Diğer işlemlerden farklı olarak eğer (R)READ işlemi yaptıysak o zaman VSAM dosyamızdan okuduğumuz bu satırın icerigini İsim Soyisim, Dogum Tarihi(Gregorian olarak), Bütçe(Dolar olarak) şeklinde yazdıracağız.

---

## **Sub Program, Program Linkage, CALL, ENTRY**

Projemizde bir alt program kullandık. Bu alt programı kullanmak için öncelikle ana programımızı çalıştırdığımız JCL'imizde alt programımızı bir kaynak kod haline çevirdik. Daha sonra ana programımızı tetiklediğimiz yerde bu alt programın kaynak kodunu ana programımıza LIBRARY olarak verdik. Bu sayede artık ana programımızın içinden alt programımızı çalıştırabileceğiz. Aslında daha yaygın bir dille ifade edersek alt programımızı bir fonksiyonlar bütünü olarak ana programımıza dahil ettik. Fakat eğer isteseydik ana programımızdan alt programımızın içinde SADECE spesifik olarak istediğimiz bir bölümü de çalıştırabilirdik. Bu bizim için daha performanslı olurdu. Fakat bu projede EVALUATE kullanımını görmek adına hocamızın da yönlendirmesiyle diğer yolu tercih ettik.

JCL'de alt programımızı bağladıktan sonra ana programımızda CALL terimi ile alt programı çalıştırabiliyoruz. Ana programımızdan alt programımıza ayrıca değişken veya entity yollamak istiyorsak CALL statementımızın yanında bu içeriği de veriyoruz. Bu içeriğin alt program tarafından değiştirilmesine izin veriyorsak REFERENCE terimi ile, eğer sadece alt program tarafından okunmasını istiyorsak veya yapılan değişikliğin alt programda kalmasını istiyorsak CONTENT terimi ile değişken grubumuzu belirtiyoruz. 

Alt programımızda LINKAGE SECTION bölümünde yer alan değişken grubu bize ana program tarafından gönderilen değişken grubudur. Bu değişkenleri alt programımızda değiştirebiliriz. İlk paragrafta bahsettiğimiz, programın daha performanslı olmasına dayalı olan yolu tercih etseydik, o zaman alt programımızda ENTRY ifadesi ile direkt olarak ana programda CALL ile belirtilen fonksiyonu çalıştırabilirdik. Bu şekliyle alt program en baştan itibaren okunmaz ve direkt olarak istenilen fonksiyon çalıştırılırdı. Bu da bir nevi kütüphane mantığı oluşturmamızı sağlıyor. Çünkü ana programdan başka bir programda yer alan fonksiyonu çalıştırıyoruz.

## Proje İçi Detaylı Not ( JCL Açıklamaları )
#### DELDEF01.JCL
<p align="left">
  <img width="480" height="370" src="https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/deldef01-1.png?raw=true">
  <img width="510" height="370" src="https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/deldef01-2.png?raw=true">
</p>

#### JREALIDX.JCL
<p align="left">
  <img width="480" height="480" src="https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/jrealidx-1.png?raw=true">
  <img width="480" height="480" src="https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/jrealidx-2.png?raw=true">
</p>

#### Z2PREVSA.JCL
<p align="left">
  <img width="480" height="480" src="https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/z2prevsa1.png?raw=true">
  <img width="480" height="480" src="https://github.com/buozdemi/kodluyoruzilkrepo/blob/main/img/Comment%20Photos/z2prevsa2.png?raw=true">
</p>

