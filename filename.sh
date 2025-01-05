#!/bin/bash

# CSV Dosya Kontrolleri
initialize_csv() {
    for file in depo.csv kullanici.csv log.csv; do
        if [[ ! -f "$file" ]]; then
            touch "$file"
            echo "$file dosyası oluşturuldu." >> log.csv
        fi
    done

    # Varsayılan bir kullanıcı ekleyelim (kullanıcı adı: samet, şifre: 123)
    if ! grep -q "samet," kullanici.csv; then
        local sifre_md5
        sifre_md5=$(echo -n "123" | md5sum | awk '{print $1}')
        echo "samet,$sifre_md5,Yönetici" >> kullanici.csv
        echo "Varsayılan kullanıcı (samet) eklendi." >> log.csv
    fi
}

# Kullanıcı Giriş Ekranı
giris_ekrani() {
    local deneme_hakki=3

    while true; do
        if [[ ! -s kullanici.csv ]]; then
            zenity --info --text="Sistemde kayıtlı kullanıcı bulunmamaktadır. Lütfen bir yönetici hesabı oluşturunuz."
            kullanici_yonetimi
        fi

        KULLANICI=$(zenity --entry --title="Giriş" --text="Kullanıcı Adınızı Giriniz:") || exit
        if [[ -f log.csv && $(grep -c "^$KULLANICI$" log.csv) -gt 0 ]]; then
            zenity --error --text="Hesabınız kilitlenmiş. Lütfen yöneticiyle iletişime geçin."
            echo "$(date '+%Y-%m-%d %H:%M:%S'),$KULLANICI,Hesap kilitli (Giriş Denemesi)" >> log.csv
            continue
        fi
        SIFRE=$(zenity --password --title="Giriş") || exit
        if dogrula_kullanici "$KULLANICI" "$SIFRE"; then
            zenity --info --text="Giriş başarılı. Hoş geldiniz, $KULLANICI!"
            ANA_MENU_KULLANICI="$KULLANICI"
            break
        else
            deneme_hakki=$((deneme_hakki - 1))
            zenity --error --text="Kullanıcı adı veya şifre hatalı. Kalan deneme hakkı: $deneme_hakki"
            if [[ $deneme_hakki -eq 0 ]]; then
                zenity --error --text="Hesabınız 3 başarısız giriş nedeniyle kilitlendi."
                echo "$KULLANICI" >> log.csv
                echo "$(date '+%Y-%m-%d %H:%M:%S'),$KULLANICI,Hesap kilitlendi" >> log.csv
                continue
            fi
        fi
    done
}


# Kullanıcı Doğrulama İşlemi
dogrula_kullanici() {
    local kullanici=$1
    local sifre=$2
    local sifre_md5
    sifre_md5=$(echo -n "$sifre" | md5sum | awk '{print $1}')

    if [[ ! -s kullanici.csv ]]; then
        zenity --error --text="Sistemde kayıtlı kullanıcı bulunmamaktadır. Yöneticiye başvurunuz."
        exit 1
    fi

    if [[ -f log.csv && $(grep -c "^$kullanici$" log.csv) -gt 0 ]]; then
        zenity --error --text="Hesabınız kilitlenmiş. Lütfen yöneticiyle iletişime geçin."
        echo "$(date '+%Y-%m-%d %H:%M:%S'),$kullanici,Hesap kilitli (Doğrulama)" >> log.csv
        return 1
    fi

    if grep -q "^$kullanici,$sifre_md5" kullanici.csv; then
        return 0
    else
        return 1
    fi
}


# Ana Menü
ana_menu() {
    local rol=$(kullanici_rol "$ANA_MENU_KULLANICI")

    while true; do
        SECIM=$(zenity --list --title="Ana Menü" \
            --column="İşlem Numarası" --column="İşlem" \
            1 "Ürün Ekle" \
            2 "Ürün Listele" \
            3 "Ürün Güncelle" \
            4 "Ürün Sil" \
            5 "Rapor Al" \
            6 "Kullanıcı Yönetimi" \
            7 "Program Yönetimi" \
            8 "Çıkış") || exit

        case $SECIM in
            1) if [[ "$rol" == "Yönetici" ]]; then urun_ekle; else yetki_hatasi; fi ;;
            2) urun_listele ;;
            3) if [[ "$rol" == "Yönetici" ]]; then urun_guncelle; else yetki_hatasi; fi ;;
            4) if [[ "$rol" == "Yönetici" ]]; then urun_sil; else yetki_hatasi; fi ;;
            5) rapor_al ;;
            6) if [[ "$rol" == "Yönetici" ]]; then kullanici_yonetimi; else yetki_hatasi; fi ;;
            7) program_yonetimi ;;
            8) zenity --question --text="Sistemden çıkmak istediğinizden emin misiniz?" && exit ;;
            *) zenity --error --text="Geçersiz seçim." ;;
        esac
    done
}

# Kullanıcı Rolü Alma İşlemi
kullanici_rol() {
    local kullanici=$1
    grep "$kullanici" kullanici.csv | awk -F',' '{print $3}'
}

# Yetki Hatası
yetki_hatasi() {
    zenity --error --text="Bu işlemi gerçekleştirmek için yetkiniz bulunmamaktadır."
}

# Ürün Ekleme Fonksiyonu
urun_ekle() {
    local urun_bilgileri
    urun_bilgileri=$(zenity --forms --title="Ürün Ekle" \
        --text="Lütfen ürün bilgilerini giriniz:" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı") || return

    local urun_adi=$(echo "$urun_bilgileri" | awk -F'|' '{print $1}')
    local stok=$(echo "$urun_bilgileri" | awk -F'|' '{print $2}')
    local fiyat=$(echo "$urun_bilgileri" | awk -F'|' '{print $3}')
    local tarih_saat
    tarih_saat=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ -z "$urun_adi" || -z "$stok" || -z "$fiyat" ]]; then
        zenity --error --text="Boş alan bırakmayınız."
        echo "HATA,$tarih_saat,Boş alan bırakıldı." >> log.csv
        return
    fi

    # Ürün adı boşluk içeriyor mu kontrolü
    if [[ "$urun_adi" =~ \  ]]; then
        zenity --error --text="Ürün adı boşluk içermemelidir."
        echo "HATA,$tarih_saat,Ürün adı boşluk içeriyor ($urun_adi)." >> log.csv
        return
    fi

    if ! [[ "$stok" =~ ^[0-9]+$ && "$fiyat" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]]; then
        zenity --error --text="Stok ve fiyat pozitif sayı olmalıdır."
        echo "HATA,$tarih_saat,Geçersiz stok veya fiyat girdisi (Stok: $stok, Fiyat: $fiyat)." >> log.csv
        return
    fi

    if grep -q "$urun_adi" depo.csv; then
        zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
        echo "HATA,$tarih_saat,Ürün zaten mevcut ($urun_adi)." >> log.csv
        return
    fi
    (
    echo "0"; sleep 1
    echo "# Ürün bilgileri kontrol ediliyor..."; sleep 1
    echo "50"; sleep 1
    echo "# Ürün ekleniyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Ürün Ekleme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close

    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi

    local urun_no
    urun_no=$(($(tail -n 1 depo.csv | awk -F',' '{print $1}') + 1))

    echo "$urun_no,$urun_adi,$stok,$fiyat" >> depo.csv
    zenity --info --text="Ürün başarıyla eklendi."
}

# Ürün Listeleme Fonksiyonu
urun_listele() {
    if [[ ! -s depo.csv ]]; then
        zenity --info --text="Envanterde ürün bulunmamaktadır."
        return
    fi
    (
    echo "0"; sleep 1
    echo "# Ürünler yükleniyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Ürün Listeleme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close
    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi

	
    zenity --text-info --title="Ürün Listesi" --filename=depo.csv
}

# Ürün Güncelleme Fonksiyonu
urun_guncelle() {
    local urun_no
    urun_no=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürün numarasını giriniz:") || return

    if ! grep -q "^$urun_no," depo.csv; then
        zenity --error --text="Bu numaraya ait bir ürün bulunamadı."
        return
    fi

    local yeni_bilgiler
    yeni_bilgiler=$(zenity --forms --title="Ürün Güncelle" \
        --text="Yeni ürün bilgilerini giriniz:" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı") || return

    local yeni_urun_adi=$(echo "$yeni_bilgiler" | awk -F'|' '{print $1}')
    local yeni_stok=$(echo "$yeni_bilgiler" | awk -F'|' '{print $2}')
    local yeni_fiyat=$(echo "$yeni_bilgiler" | awk -F'|' '{print $3}')

    if [[ -z "$yeni_urun_adi" || -z "$yeni_stok" || -z "$yeni_fiyat" ]]; then
        zenity --error --text="Boş alan bırakmayınız."
        return
    fi

    if ! [[ "$yeni_stok" =~ ^[0-9]+$ && "$yeni_fiyat" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]]; then
        zenity --error --text="Stok ve fiyat pozitif sayı olmalıdır."
        return
    fi
    zenity --question --text="Ürün No: $urun_no güncellenecek. Devam etmek istiyor musunuz?" || return
    (
    echo "0"; sleep 1
    echo "# Ürün bilgileri kontrol ediliyor..."; sleep 1
    echo "50"; sleep 1
    echo "# Ürün güncelleniyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Ürün Güncelleme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close
    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi

    sed -i "/^$urun_no,/c\\$urun_no,$yeni_urun_adi,$yeni_stok,$yeni_fiyat" depo.csv
    zenity --info --text="Ürün başarıyla güncellendi."
}

# Ürün Silme Fonksiyonu
urun_sil() {
    local urun_adi
    urun_adi=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürün adını giriniz:") || return

    if ! grep -q ",$urun_adi," depo.csv; then
        zenity --error --text="Bu ada ait bir ürün bulunamadı."
        return
    fi

    zenity --question --text="Ürün Adı: $urun_adi silinecek. Devam etmek istiyor musunuz?" || return	

    (
        echo "0"; sleep 1
        echo "# Ürün bilgileri kontrol ediliyor..."; sleep 1
        echo "50"; sleep 1
        echo "# Ürün siliniyor..."; sleep 1
        echo "100"; sleep 1
    ) | zenity --progress --title="Ürün Silme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close

    if [ $? -eq 1 ]; then
        zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
        return
    fi

    sed -i "/,$urun_adi,/d" depo.csv
    zenity --info --text="Ürün başarıyla silindi."
}

# Rapor Alma Fonksiyonu
rapor_al() {
    local rapor_dosyasi secim

    # Kullanıcıdan seçim alın
    secim=$(zenity --list \
        --title="Rapor Türü Seçimi" \
        --column="Seçim" --column="Açıklama" \
        "1" "Stokta Azalan Ürünler" \
        "2" "En Yüksek Stok Miktarına Sahip Ürün" \
        --height=200 --width=400) || return

    # Rapor kaydedilecek dosyayı seçtir
    rapor_dosyasi=$(zenity --file-selection --save --title="Rapor Kaydet" --confirm-overwrite) || return

    case $secim in
        "1")
            # Stokta azalan ürünler: Stok miktarı 10'dan az olanlar
            awk -F"," '$3 < 10 {print $0}' depo.csv > "$rapor_dosyasi"
            zenity --info --text="Stokta azalan ürünler raporu başarıyla kaydedildi: $rapor_dosyasi"
            ;;
        "2")
            # En yüksek stok miktarına sahip ürün
            awk -F"," 'NR==1 || $3 > max {max=$3; line=$0} END {print line}' depo.csv > "$rapor_dosyasi"
            zenity --info --text="En yüksek stok miktarına sahip ürün raporu başarıyla kaydedildi: $rapor_dosyasi"
            ;;
        *)
            zenity --error --text="Geçersiz seçim yapıldı."
            return
            ;;
    esac
}


# Kullanıcı Yönetimi Fonksiyonu
kullanici_yonetimi() {
    SECIM=$(zenity --list --title="Kullanıcı Yönetimi" \
        --column="İşlem Numarası" --column="İşlem" \
        1 "Kullanıcı Ekle" \
        2 "Kullanıcı Sil" \
        3 "Kullanıcı Listele" \
        4 "Kullanıcı Güncelle" \
        5 "Şifre Sıfırla" \
        6 "Kilitli Hesap Aç" \
        7 "Geri Dön") || return

    case $SECIM in
        1) kullanici_ekle ;;
        2) kullanici_sil ;;
        3) kullanicilari_listele ;;
        4) kullanici_guncelle ;;
        5) sifre_sifirla ;;         # Şifre sıfırlama işlevi çağrılır
        6) kilitli_hesap_ac ;;             # Kilitli hesabı açma işlevi çağrılır
        7) return ;;
        *) zenity --error --text="Geçersiz seçim." ;;
    esac
}


# Kullanıcı Ekleme Fonksiyonu
kullanici_ekle() {
    local kullanici_bilgileri
    kullanici_bilgileri=$(zenity --forms --title="Kullanıcı Ekle" \
        --text="Yeni kullanıcı bilgilerini giriniz:" \
        --add-entry="Kullanıcı Adı" \
        --add-password="Şifre" \
        --add-entry="Rol (Yönetici/Kullanıcı)") || return

    local kullanici=$(echo "$kullanici_bilgileri" | awk -F'|' '{print $1}')
    local sifre=$(echo "$kullanici_bilgileri" | awk -F'|' '{print $2}')
    local rol=$(echo "$kullanici_bilgileri" | awk -F'|' '{print $3}')

    if [[ -z "$kullanici" || -z "$sifre" || -z "$rol" ]]; then
        zenity --error --text="Boş alan bırakmayınız."
        return
    fi
    (
    echo "0"; sleep 1
    echo "# Kullanıcı bilgileri kontrol ediliyor..."; sleep 1
    echo "50"; sleep 1
    echo "# Kullanıcı ekleniyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Kullanıcı Ekleme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close
    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi


    local sifre_md5
    sifre_md5=$(echo -n "$sifre" | md5sum | awk '{print $1}')

    echo "$kullanici,$sifre_md5,$rol" >> kullanici.csv
    zenity --info --text="Kullanıcı başarıyla eklendi."
}

# Kullanıcı Silme Fonksiyonu
kullanici_sil() {
    local kullanici
    kullanici=$(zenity --entry --title="Kullanıcı Sil" --text="Silmek istediğiniz kullanıcı adını giriniz:") || return

    if ! grep -q "^$kullanici," kullanici.csv; then
        zenity --error --text="Bu kullanıcı adı bulunamadı."
        return
    fi
    zenity --question --text="Kullanıcı '$kullanici_adi' silinecek. Devam etmek istiyor musunuz?" || return
    (
    echo "0"; sleep 1
    echo "# Kullanıcı bilgileri kontrol ediliyor..."; sleep 1
    echo "50"; sleep 1
    echo "# Kullanıcı siliniyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Kullanıcı Silme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close
    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi

    sed -i "/^$kullanici,/d" kullanici.csv
    zenity --info --text="Kullanıcı başarıyla silindi."
}

# Kullanıcıları Listeleme Fonksiyonu
kullanicilari_listele() {
    if [[ ! -s kullanici.csv ]]; then
        zenity --info --text="Sistemde kayıtlı kullanıcı bulunmamaktadır."
        return
    fi
    (
    echo "0"; sleep 1
    echo "# Kullanıcılar yükleniyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Kullanıcı Listeleme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close
    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi


    zenity --text-info --title="Kayıtlı Kullanıcılar" --filename=kullanici.csv
}

kullanici_guncelle() {
    local kullanici
    kullanici=$(zenity --entry --title="Kullanıcı Güncelle" --text="Güncellemek istediğiniz kullanıcı adını giriniz:") || return

    if ! grep -q "^$kullanici," kullanici.csv; then
        zenity --error --text="Bu kullanıcı adı bulunamadı."
        return
    fi

    local yeni_bilgiler
    yeni_bilgiler=$(zenity --forms --title="Kullanıcı Güncelle" \
        --text="Yeni bilgileri giriniz:" \
        --add-entry="Yeni Kullanıcı Adı" \
        --add-password="Yeni Şifre" \
        --add-entry="Yeni Rol (Yönetici/Kullanıcı)") || return

    local yeni_kullanici=$(echo "$yeni_bilgiler" | awk -F'|' '{print $1}')
    local yeni_sifre=$(echo "$yeni_bilgiler" | awk -F'|' '{print $2}')
    local yeni_rol=$(echo "$yeni_bilgiler" | awk -F'|' '{print $3}')

    if [[ -z "$yeni_kullanici" || -z "$yeni_sifre" || -z "$yeni_rol" ]]; then
        zenity --error --text="Boş alan bırakmayınız."
        return
    fi
    zenity --question --text="Kullanıcı '$kullanici_adi' güncellenecek. Devam etmek istiyor musunuz?" || return
    (
    echo "0"; sleep 1
    echo "# Kullanıcı bilgileri kontrol ediliyor..."; sleep 1
    echo "50"; sleep 1
    echo "# Kullanıcı güncelleniyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Kullanıcı Güncelleme İşlemi" --text="İşlem devam ediyor..." --percentage=0 --auto-close
    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi


    local yeni_sifre_md5
    yeni_sifre_md5=$(echo -n "$yeni_sifre" | md5sum | awk '{print $1}')

    # Eski kaydı sil ve yeni kaydı ekle
    sed -i "/^$kullanici,/d" kullanici.csv
    echo "$yeni_kullanici,$yeni_sifre_md5,$yeni_rol" >> kullanici.csv

    zenity --info --text="Kullanıcı başarıyla güncellendi."
}

# Program Yönetimi Fonksiyonu
program_yonetimi() {
    (
    echo "0"; sleep 1
    echo "# Program yönetimi başlatılıyor..."; sleep 1
    echo "50"; sleep 1
    echo "# Gerekli kontroller yapılıyor..."; sleep 1
    echo "100"; sleep 1
    ) | zenity --progress --title="Program Yönetimi" --text="İşlem devam ediyor..." --percentage=0 --auto-close
    if [ $? -eq 1 ]; then
    zenity --error --text="İşlem kullanıcı tarafından iptal edildi."
    fi

    local islem
    islem=$(zenity --list --title="Program Yönetimi" \
        --column="Seçim" --column="İşlem" \
        1 "Diskteki Alanı Göster" \
        2 "Diske Yedekle" \
        3 "Hata Kayıtlarını Göster" \
        4 "Geri Dön") || return

    case $islem in
        1) 
           local temp_file="disk_bilgisi.txt"
            du -h depo.csv kullanici.csv log.csv 2>/dev/null > "$temp_file"

            if [[ -s "$temp_file" ]]; then
                zenity --text-info --title="Diskteki Alan" --filename="$temp_file"
            else
                zenity --error --text="Dosyalar bulunamadı veya erişilemiyor."
            fi

            rm -f "$temp_file"
            ;;
        2) 
            local yedek_dizin
            yedek_dizin=$(zenity --file-selection --directory --title="Yedekleme Dizini Seçin") || return

            if [[ -d "$yedek_dizin" ]]; then
                cp depo.csv kullanici.csv "$yedek_dizin"
                zenity --info --text="Dosyalar başarıyla yedeklendi: $yedek_dizin"
            else
                zenity --error --text="Geçerli bir dizin seçilmedi."
            fi
            ;;
        3) 
            if [[ ! -s log.csv ]]; then
                zenity --info --text="Hata kayıt dosyası (log.csv) boş veya mevcut değil."
            else
                zenity --text-info --title="Hata Kayıtları" --filename=log.csv
            fi
            ;;
        4) 
            return 
            ;;
        *) 
            zenity --error --text="Geçersiz seçim." 
            ;;
    esac
}
sifre_sifirla() {
    local kullanici_adi
    kullanici_adi=$(zenity --entry --title="Şifre Sıfırla" --text="Şifresini sıfırlamak istediğiniz kullanıcı adını giriniz:") || return

    if ! grep -q "^$kullanici_adi," kullanici.csv; then
        zenity --error --text="Bu kullanıcı adıyla kayıt bulunamadı."
        return
    fi

    local yeni_sifre
    yeni_sifre=$(zenity --password --title="Yeni Şifre Belirle" --text="Kullanıcı için yeni şifreyi giriniz:") || return

    if [[ -z "$yeni_sifre" ]]; then
        zenity --error --text="Şifre boş bırakılamaz."
        return
    fi

    local yeni_sifre_md5
    yeni_sifre_md5=$(echo -n "$yeni_sifre" | md5sum | awk '{print $1}')

    # Kullanıcı kaydını bul ve mevcut rolünü al
    local mevcut_kayit mevcut_rol
    mevcut_kayit=$(grep "^$kullanici_adi," kullanici.csv)
    mevcut_rol=$(echo "$mevcut_kayit" | awk -F',' '{print $3}')

    # Eski kaydı sil ve yeni kaydı ekle
    sed -i "/^$kullanici_adi,/d" kullanici.csv
    echo "$kullanici_adi,$yeni_sifre_md5,$mevcut_rol" >> kullanici.csv

    zenity --info --text="Şifre başarıyla sıfırlandı."
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$kullanici_adi,Şifre sıfırlandı" >> log.csv
}

kilitli_hesap_ac() {
    local kilitli_hesaplar
    kilitli_hesaplar=$(grep "Hesap kilitlendi" log.csv | awk -F',' '{print $2}' | sort | uniq)

    if [[ -z "$kilitli_hesaplar" ]]; then
        zenity --info --text="Kilitli hiçbir hesap bulunmamaktadır."
        return
    fi

    local secilen_kullanici
    secilen_kullanici=$(echo "$kilitli_hesaplar" | zenity --list --title="Kilitli Hesap Aç" \
        --column="Kullanıcı Adı" --text="Açmak istediğiniz kilitli hesabı seçin:") || return

    if [[ -z "$secilen_kullanici" ]]; then
        zenity --error --text="Hiçbir kullanıcı seçilmedi."
        return
    fi

    zenity --question --text="Seçilen kullanıcı: $secilen_kullanici\nHesabı açmak istediğinizden emin misiniz?" || return

    # Kilitli hesaptan ilgili girişleri log.csv'den kaldır
    sed -i "/$secilen_kullanici,Hesap kilitlendi/d" log.csv

    # İşlem başarıyla tamamlandı mesajı
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$secilen_kullanici,Hesap açıldı (Yönetici)" >> log.csv
    zenity --info --text="Kullanıcı hesabı başarıyla açıldı: $secilen_kullanici"
}

# Program Başlatma
initialize_csv
giris_ekrani
ana_menu

