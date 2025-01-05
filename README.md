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
8. [Geliştirme Notları](#-geliştirme-notları)  
9. [Katkıda Bulunma](#-katkıda-bulunma)  
10. [İletişim](#-iletişim)  
11. [Lisans](#-lisans)  

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
