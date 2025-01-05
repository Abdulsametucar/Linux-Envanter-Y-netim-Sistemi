# 📦 Stok ve Kullanıcı Yönetim Sistemi

Bu proje, **Bash Script** ile geliştirilmiş bir stok ve kullanıcı yönetim sistemidir. **Zenity** kullanılarak görsel arayüz desteği sağlanmış, temel stok yönetimi ve kullanıcı erişim kontrolü fonksiyonları eklenmiştir. Sistem, kullanıcıların kolay ve etkili bir şekilde depo işlemlerini gerçekleştirmesi için tasarlanmıştır.

---

## 📋 İçindekiler

1. [Projenin Amacı](#-projenin-amacı)  
2. [Özellikler](#-özellikler)  
3. [Gereksinimler](#-gereksinimler)  
4. [Kurulum ve Çalıştırma](#-kurulum-ve-çalıştırma)  
5. [Kullanım Rehberi](#-kullanım-rehberi)  
    - [Giriş Sistemi](#-giriş-sistemi)  
    - [Ana Menü ve İşlevler](#-ana-menü-ve-işlevler)  
    - [Stok Yönetimi](#-stok-yönetimi)  
    - [Kullanıcı Yönetimi](#-kullanıcı-yönetimi)  
    - [Raporlama](#-raporlama)  
6. [Dosya Yapısı](#-dosya-yapısı)  
7. [Loglama ve Hata Yönetimi](#-loglama-ve-hata-yönetimi)  

---

## 🎯 Projenin Amacı

Bu projenin amacı:
- **Depo yönetimini kolaylaştırmak:** Ürünlerin eklenmesi, güncellenmesi, silinmesi ve listelenmesi gibi işlemler kullanıcı dostu bir arayüz ile sağlanmıştır.
- **Kullanıcı yönetimi sağlamak:** Yetkilendirme ve erişim kontrol mekanizmaları ile kullanıcıların güvenli bir şekilde sisteme giriş yapması desteklenmiştir.
- **Hata ve işlem kaydı tutmak:** Loglama sistemi ile tüm işlemler kayıt altına alınır, bu sayede takip ve denetim kolaylaşır.

---






## ✨ Özellikler

- **Zenity Tabanlı Görsel Arayüz:** Kullanıcılar komut satırı yerine pop-up formlar ve tablolar ile işlem yapabilir.
- **Rol Tabanlı Yetkilendirme:** Kullanıcılar "Yönetici" veya "Kullanıcı" rollerine sahiptir.
- **Çoklu İşlevsellik:** Depo, kullanıcı ve raporlama işlemlerini destekler.
- **Loglama:** Sistem, yapılan her işlemi `log.csv` dosyasına yazar.

---

## 📦 Gereksinimler

Projeyi çalıştırmak için aşağıdaki gereksinimlere ihtiyacınız vardır:

1. **Linux İşletim Sistemi**  
2. **Zenity**: Sisteminizde yüklü değilse aşağıdaki komutla yükleyebilirsiniz:
   ```bash
   sudo apt install zenity

## 🚀 Kurulum ve Çalıştırma
Proje dosyasını indirin:


Script'i çalıştırılabilir hale getirin:


    chmod +x scriptadi.sh
Script'i başlatın:


    ./scriptadi.sh
Giriş ekranı açılacaktır. Varsayılan yönetici bilgileri:


    Kullanıcı Adı: samet
    Şifre: 123
##  📖 Kullanım Rehberi
### 🔑 Giriş Sistemi
Kullanıcı, sistemde kayıtlı kullanıcı adı ve şifre bilgileri ile giriş yapar.
Başarısız girişler: 3 kez hatalı giriş yapılırsa hesap kilitlenir.
Kilitli hesaplar sadece yönetici tarafından tekrar aktif edilebilir.
##  🏠 Ana Menü ve İşlevler
Sisteme giriş yaptıktan sonra kullanıcı yetkisine göre şu menüler gösterilir:

**Yönetici Menüsü:**

Ürün işlemleri (Ekleme, güncelleme, silme, listeleme).
Kullanıcı işlemleri (Ekleme, düzenleme, silme, şifre sıfırlama).
Raporlama işlemleri.
Log kayıtlarını görüntüleme.
**Kullanıcı Menüsü:**

Ürün listeleme.
Raporlama.
## 📦 Stok Yönetimi
**Ürün Ekleme:**

Ürün bilgileri (Ürün No, Ürün Adı, Stok Miktarı, Birim Fiyatı) form aracılığıyla alınır.
Veri depo.csv dosyasına eklenir.
**Ürün Listeleme:**

Tüm ürünler görsel bir tabloda listelenir.
**Ürün Güncelleme:**

Ürün No'suna göre ürün bilgileri düzenlenebilir.
**Ürün Silme:**

Ürün No veya Ürün Adı bilgisiyle, ilgili ürün sistemden kaldırılır.
##  👥 Kullanıcı Yönetimi
**Kullanıcı Ekleme:** Yeni bir kullanıcı (Kullanıcı Adı, Şifre, Rol) eklenir.
**Kullanıcı Silme:** Var olan kullanıcı sistemden silinir.
**Kullanıcı Güncelleme:** Kullanıcı adı veya şifre gibi bilgiler düzenlenebilir.
**Şifre Sıfırlama:** Kullanıcının şifresi yeniden belirlenebilir.
**Hesap Kilit Açma:** Kilitli kullanıcılar yönetici tarafından aktif hale getirilebilir.
## 📊 Raporlama
**Stok Raporları:**

**Azalan Stok Ürünleri:** Stok miktarı 10’dan az olan ürünler raporlanır.
**En Fazla Stok Ürünü:** Depodaki en yüksek stok miktarına sahip ürün raporlanır.
**Rapor Kaydetme:**

Raporlar, kullanıcı tarafından seçilen dosya yoluna kaydedilir.
##  📂 Dosya Yapısı
**scriptadi.sh:** Projenin ana dosyasıdır.
**depo.csv:** Ürün bilgilerini saklayan dosya (Ürün No, Ürün Adı, Stok, Fiyat).
**kullanici.csv:** Kullanıcı bilgilerini saklayan dosya (Kullanıcı Adı, Şifre, Rol).
**log.csv:** Tüm işlemleri ve hataları kayıt altına alır.
## 📜 Loglama ve Hata Yönetimi
Tüm işlemler ve hatalar log.csv dosyasına yazılır.

**Başlıca log türleri:**
Kullanıcı giriş/çıkış bilgileri.
Ürün işlemleri (ekleme, silme, güncelleme).
Kilitli hesap denemeleri.
Rapor oluşturma kayıtları.

![image](https://github.com/user-attachments/assets/0c1ba4cc-911b-48c9-9bf5-3d445f599392) ![image](https://github.com/user-attachments/assets/26add8c8-9713-47a0-aa23-4c460291c4b1) ![image](https://github.com/user-attachments/assets/c690ae78-b9e3-4b3b-bbf2-1c16626e2551) ![image](https://github.com/user-attachments/assets/2260c913-5b79-4029-8b72-1b8ba2014962)
 ![image](https://github.com/user-attachments/assets/347bf89b-7a60-4147-8c42-59fb3328d2f6) ![image](https://github.com/user-attachments/assets/7ba3d789-ae8e-4f81-999f-b91a85887ef9) ![image](https://github.com/user-attachments/assets/598b569f-b112-452c-8e97-232499bdac61) ![image](https://github.com/user-attachments/assets/032d2ba1-960c-409e-83d3-177b6f587d74) ![image](https://github.com/user-attachments/assets/9261edf8-a8f9-471e-a4d6-4826b166aea0)


