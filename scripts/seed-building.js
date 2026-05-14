// Seed the "Сүлжээ Хичээлийн I байр" building (4 floors) into Firestore.
// Usage: node scripts/seed-building.js
//
// Requires ../service-account.json (same as grant-admin.js).

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(require('../service-account.json')),
});

const buildingId = 'syl1';
const buildingName = 'Сүлжээ Хичээлийн I байр';

// Helper. Each room: [number, mongolianName, type]
const tFloor = (rooms) => rooms.map(([number, name, type]) =>
  ({ number: String(number), name, type: type || 'office' }));

const floors = {
  // Floor B1 — basement (numbered 0 in the PDF). We store as floor: 0.
  0: tFloor([
    ['001', 'Виртуал лаб', 'lab'],
    ['002', 'ХАБЭА лаб', 'lab'],
    ['003', 'Хичээлийн танхим', 'classroom'],
    ['004', 'Мужааны өрөө', 'lab'],
    ['005', 'Багш нарын өрөө', 'office'],
    ['006', 'Склад-1', 'storage'],
    ['007', 'Ажилчдын өрөө', 'office'],
    ['008', 'Склад-2', 'storage'],
    ['009', 'Дадлагын газар', 'lab'],
    ['010', 'Металл судлалын лаб', 'lab'],
    ['011', 'Токарын лаб', 'lab'],
    ['012', 'Авто оношилгоо засварын газар', 'lab'],
    ['013', 'Багш нарын өрөө', 'office'],
    ['014', 'Хичээлийн танхим', 'classroom'],
    ['015', 'Симуляторын лаб', 'lab'],
    ['016', 'Багш нарын өрөө', 'office'],
    ['017', 'ШИТ-ны өрөө', 'office'],
    ['018', 'Ажилчдын өрөө', 'office'],
    ['019', 'Багш нарын өрөө', 'office'],
    ['020', 'Цахилгаан лаб-1', 'lab'],
    ['021', 'Цахилгаан лаб-2', 'lab'],
    ['022', 'Гидрометаллургийн лаб', 'lab'],
    ['023', 'Хими/Гидравлик/Баяжуулалтын лаб', 'lab'],
    ['024', 'Мэргэжлийн сургалтын склад', 'storage'],
  ]),
  1: tFloor([
    ['101', 'Хичээлийн танхим', 'classroom'],
    ['102', 'Хичээлийн танхим', 'classroom'],
    ['103', 'Хичээлийн танхим', 'classroom'],
    ['104', 'Хичээлийн танхим', 'classroom'],
    ['105', 'Албан өрөө', 'office'],
    ['106', 'Албан өрөө', 'office'],
    ['107', 'Албан өрөө', 'office'],
    ['108', 'Багш нарын өрөө', 'office'],
    ['109', 'Багш нарын өрөө', 'office'],
    ['110', 'Албан/Багш нарын өрөө', 'office'],
    ['111', 'Албан/Багш нарын өрөө', 'office'],
    ['112', 'Албан/Багш нарын өрөө', 'office'],
    ['113', 'Албан/Багш нарын өрөө', 'office'],
    ['114', 'Албан/Багш нарын өрөө', 'office'],
    ['115', 'Уншлагын танхим', 'classroom'],
    ['116', 'Номын фонд', 'storage'],
    ['117', 'Номын фонд-1', 'storage'],
    ['118', 'Номын сангийн эрхлэгч', 'office'],
    ['119', 'VIP өрөө', 'meeting'],
    ['120', 'Гал тогоо', 'cafeteria'],
    ['121', 'Бэлтгэлийн өрөө', 'storage'],
    ['122', 'Угаалгын өрөө', 'restroom'],
    ['123', 'Албан өрөө', 'office'],
    ['124', 'Склад', 'storage'],
    ['125', 'Хоолны зал', 'cafeteria'],
    ['126', 'Албан өрөө', 'office'],
    ['127', 'Коридор', 'other'],
    ['128', 'ШИТ-ний танхим', 'classroom'],
    ['129', '00 өрөө', 'restroom'],
    ['130', '00 өрөө', 'restroom'],
    ['131', 'Электрон номын сан', 'classroom'],
    ['132', 'Мэдээлэлийн төв', 'office'],
    ['133', 'Коридор', 'other'],
    ['134', 'Серверийн өрөө', 'storage'],
    ['135', 'Агааржуулалтын өрөө', 'storage'],
    ['136', '00 өрөө', 'restroom'],
    ['137', 'Коридор', 'other'],
  ]),
  2: tFloor([
    ['201', 'Фонд', 'storage'],
    ['202', 'Ком лаб', 'lab'],
    ['203', 'Багш нарын өрөө', 'office'],
    ['204', 'Багш нарын өрөө', 'office'],
    ['205', 'Албан өрөө', 'office'],
    ['206', 'Эрдмийн зөвлөлийн өрөө', 'meeting'],
    ['207', 'Захирлын өрөө', 'office'],
    ['207B', 'Захирлын нарийн бичиг', 'office'],
    ['208', 'Албан өрөө', 'office'],
    ['209', 'Сургалт эрхэлсэн дэд захирал', 'office'],
    ['210', 'Албан өрөө', 'office'],
    ['211', 'Албан өрөө', 'office'],
    ['212', 'Багш нарын өрөө', 'office'],
    ['213', 'Багш нарын өрөө', 'office'],
    ['214', 'Лекцийн зал', 'classroom'],
    ['215', 'Албан өрөө', 'office'],
    ['216', 'Багш нарын өрөө', 'office'],
    ['217', 'Албан өрөө', 'office'],
    ['218', 'Албан өрөө', 'office'],
    ['219', 'Бялдаржуулах өрөө', 'lab'],
    ['220', 'Спорт зал', 'classroom'],
    ['221', 'Коридор', 'other'],
    ['222', 'Хувцас солих өрөө', 'storage'],
    ['223', 'ДУШ', 'restroom'],
    ['224', 'Багшийн өрөө', 'office'],
    ['225', 'Хувцасны склад', 'storage'],
    ['226', 'Коридор', 'other'],
    ['227', 'Хүндэтгэлийн танхим', 'meeting'],
    ['228', 'Галерей', 'meeting'],
  ]),
  3: tFloor([
    ['301', 'Архив', 'storage'],
    ['302', 'Хичээлийн танхим', 'classroom'],
    ['303', 'Хичээлийн танхим', 'classroom'],
    ['304', 'Хичээлийн танхим', 'classroom'],
    ['305', 'Хичээлийн танхим', 'classroom'],
    ['306', 'Ком лаб', 'lab'],
    ['306-А', 'Ком лаб', 'lab'],
    ['306-Б', 'Багш нарын өрөө', 'office'],
    ['307', 'Багш нарын өрөө', 'office'],
    ['308', 'Агаажуулалтын өрөө', 'storage'],
    ['309', 'Багш нарын өрөө', 'office'],
    ['310', 'Багш нарын өрөө', 'office'],
    ['311', 'Багш нарын өрөө', 'office'],
    ['312', 'Агаажуулалтын өрөө', 'storage'],
    ['313', 'Багш нарын өрөө', 'office'],
  ]),
};

(async () => {
  const db = admin.firestore();
  await db.collection('buildings').doc(buildingId).set({
    name: buildingName,
    address: 'Эрдэнэт Технологийн Дээд Сургууль',
    floorCount: 4,
    qrCode: `campus://${buildingId}`,
    companies: ['Сүлжээний инженерчлэл', 'Удирдлага', 'Лаб'],
  }, { merge: true });

  // Floor docs
  for (const f of [0, 1, 2, 3]) {
    await db
      .collection('buildings').doc(buildingId)
      .collection('floors').doc(String(f))
      .set({ width: 1000, height: 700 }, { merge: true });
  }

  // Rooms
  const batch = db.batch();
  for (const [floor, rooms] of Object.entries(floors)) {
    for (const r of rooms) {
      const id = `${buildingId}_${r.number}`;
      const ref = db
        .collection('buildings').doc(buildingId)
        .collection('rooms').doc(id);
      batch.set(ref, {
        number: r.number,
        floor: Number(floor),
        name: r.name,
        type: r.type,
        occupantIds: [],
        waypointId: `wp_${id}`,
      }, { merge: true });
    }
  }
  await batch.commit();

  console.log(`Seeded ${buildingName} (id=${buildingId}) with rooms across 4 floors.`);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
