# NLO AI INTEGRATION PACK

Bu doküman üç dosya olarak kullanılmak üzere hazırlanmıştır. İstersen birebir ayırıp proje kök dizinine koyabilirsin:

* NLO_MANIFESTO.md
* NLO_PLAYBOOK.md
* PROMPT_TEMPLATES.md

---

## NLO_MANIFESTO.md

# NLO

**NOT LIKE OTHERS**

### Tanım

**NLO — Not Like Others.**
Bu, başkalarının yanlış yaptığı anlamına gelmez.
Onlar doğru olanı yaptı. Kendileri için doğru olanı.

Ama her doğruluk bir sınır üretir.
Ve her sınır, bir başkasının başlangıç noktası olabilir.

NLO, başkalarının ulaştığı yerde durmayı reddeder.
Kendi sınırlarını başkasından ödünç almaz.

---

### Karşı Duruş

NLO kopyalamaz.
Çünkü kopya, başkasının problemini kendi çözümü sanmaktır.

NLO “standart” kelimesini sorgular.
Standartlar yol gösterebilir ama yön tayin edemez.

NLO, “sektörde böyle” cümlesini gerekçe olarak kabul etmez.
Çalışıyor olması yeterli sebep değildir.

NLO gürültüye karşıdır.
Daha fazla değil, daha anlamlı olanı arar.

NLO, geçmişteki kendisini bile sorgular.
“Ben hep böyle yapıyordum” da bir zincirdir.

---

### Niyet

NLO yön vermek için vardır.
Uymak için değil.

Her tasarımın, her ürünün “böyle olması gerekir” diye bir zorunluluğu yoktur.

NLO, görsel ve zihinsel kalıpların dışında kalmayı seçer.
En basit araç bile yeniden düşünülebilir.

İnsanlar NLO ile karşılaştığında şunu hissetmelidir:
**“Evet… Aslında böyle olması lazımmış.”**

---

### İlke

* Her şey ya anlam taşır ya da yok olur.
* Sadelik eksiltmek değil, netleştirmektir.
* Ürün kullanıcıyı eğitmez; kendini anlatır.
* Dikkat çekmek için bağırılmaz.
* Karar sayısı azaltılır, yük hafifletilir.

---

### Cesaret

NLO herkes tarafından sevilmeyi hedeflemez.

Yanlış kişiyi kaybetmek, doğru kişiyi bulmanın bedelidir.

NLO yavaş büyümeyi göze alır.
Hız, yön kaybını telafi etmez.

NLO yanlış anlaşılmayı kabul eder.
Anlaşılmak için kendini basitleştirmez.

---

### Sorumluluk

Farklı olmak bir ayrıcalık değil, bir yüktür.

NLO, özgünlük bahanesiyle özensizliği kabul etmez.

Her karar savunulabilir olmalıdır.
“İçimden geldi” yeterli gerekçe değildir.

---

### Davet

NLO bir kulüp değildir.
Bir çağrıdır.

Herkesi içeri almaz.
Ama geleni de şekillendirmeye çalışmaz.

Hazır yollar yoktur.
Ama yönünü kaybetmeyenler için alan vardır.

---

## NLO_PLAYBOOK.md

# NLO Playbook

Bu belge, manifestoyu **günlük ürün ve kod kararlarına** çevirir.

### Karar Filtresi

Her fikir bu sorulardan geçer:

* Bu gerçekten gerekli mi, yoksa alışkanlık mı?
* Bunu çıkarırsak ürün çöker mi, yoksa rahatlar mı?
* Kullanıcının karar yükü arttı mı, azaldı mı?
* Sessiz mi, yoksa bağırıyor mu?

### Varsayılan Tercihler

* Daha az özellik > Daha çok özellik
* Tek iyi yol > Çok seçenek
* Açık anlam > Süs
* Standart çözüm > yalnızca bilinçli gerekçeyle

### UI / UX İlkeleri

* İlk bakışta sade, ikinci bakışta derin
* Animasyon = anlam için, dikkat için değil
* Ayar varsa, nedeni vardır
* Kategori varsa, yük değil yön sağlar

### Kod & Mimari

* Basit olan tercih edilir
* Okunabilirlik, zekâ gösterisinden üstündür
* “Sonra bakarız” teknik borç olarak yazılır
* Gereksiz abstraction silinir

---

## PROMPT_TEMPLATES.md

# NLO Prompt Templates

### 1. Feature Tasarımı

```
Act as an NLO product designer.

Goal:
- (tek cümleyle amaç)

Constraints:
- (teknik / iş kısıtları)

Rules:
- Reduce user decision load
- Prefer removal over addition
- Quiet, confident design

Deliver:
1) Conventional solution (short)
2) NLO alternative
3) What is removed
4) Why the NLO version is better
```

---

### 2. UI / UX Tasarımı

```
Design this interface using NLO principles.

Non-negotiables:
- No decorative elements
- No default UI patterns without justification
- One primary action only

Explain:
- Visual hierarchy
- What the user does NOT see
- Where silence is used intentionally
```

---

### 3. Code Review (NLO Check)

```
Review this code as an NLO reviewer.

Answer:
1) What became simpler?
2) What became noisier?
3) Any standard patterns used? Why?
4) What can be deleted without breaking intent?
5) Verdict: PASS or REVISE (with edits)
```

---

### 4. Günlük Mini Check

```
Is this NLO?
- Does it reduce cognitive load?
- Does it avoid unnecessary choice?
- Does it feel calm?
- Would a non‑NLO team build this the same way?
```
