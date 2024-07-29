## 0.1.0

* RationalProgress sınıfında smoothUpdateInterval default değeri 200 den 50 'ye güncellendi.
* RationalProgress sınıfına isShowDebugSmoothUpdater seçeneği eklendi.
* RationalProgress sınıfında her _smoothUpdateTimer döngüsündeki debug içeriği "Current Percentage" ifadesi "Smoother Percentage" olarak güncellendi.
* example dizininde örnek proje eklendi.
* FictionalProgress sınıfında processingRatePerS ve updateIntervalMs değerinin sınıf örneği üzerinden değiştirilmesi sağlandı.
* FictionalProgress sınıfına isShowDebugPeriodicUpdate seçeneği eklendi.
* FictionalProgress sınıfına processedSizeNotifier eklendi.
* FictionalProgress sizes getter'ı ve setUpdateIntervalMs setter'ı eklendi.
* Tüm sınıfları içine alan ChildProgress soyut sınıfı yaratıldı. percentageNotifier ve uniqueName parametreleri buradan yönetilecek
* Parent Progress notifier listesi yerine artık children adında ChildProgress türünden liste alacak.

## 0.0.1

* initial release.
