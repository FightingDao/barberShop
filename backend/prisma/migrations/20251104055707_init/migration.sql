-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "nickname" VARCHAR(50),
    "avatar_url" VARCHAR(255),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "shops" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(20),
    "description" TEXT,
    "avatar_url" VARCHAR(255),
    "opening_time" TIME NOT NULL,
    "closing_time" TIME NOT NULL,
    "latitude" DECIMAL(10,8),
    "longitude" DECIMAL(11,8),
    "status" VARCHAR(20) NOT NULL DEFAULT 'active',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "shops_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "services" (
    "id" SERIAL NOT NULL,
    "shop_id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "price" DECIMAL(10,2) NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "icon_url" VARCHAR(255),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "services_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stylists" (
    "id" SERIAL NOT NULL,
    "shop_id" INTEGER NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "avatar_url" VARCHAR(255),
    "title" VARCHAR(50),
    "experience_years" INTEGER,
    "specialties" TEXT,
    "status" VARCHAR(20) NOT NULL DEFAULT 'active',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stylists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "appointments" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "shop_id" INTEGER NOT NULL,
    "service_id" INTEGER NOT NULL,
    "stylist_id" INTEGER,
    "appointment_date" DATE NOT NULL,
    "appointment_time" TIME NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'pending',
    "notes" TEXT,
    "confirmation_code" VARCHAR(10) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "appointments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "time_slots" (
    "id" SERIAL NOT NULL,
    "shop_id" INTEGER NOT NULL,
    "stylist_id" INTEGER,
    "date" DATE NOT NULL,
    "start_time" TIME NOT NULL,
    "end_time" TIME NOT NULL,
    "is_available" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "time_slots_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "appointments_confirmation_code_key" ON "appointments"("confirmation_code");

-- CreateIndex
CREATE INDEX "appointments_user_id_status_idx" ON "appointments"("user_id", "status");

-- CreateIndex
CREATE INDEX "appointments_appointment_date_appointment_time_idx" ON "appointments"("appointment_date", "appointment_time");

-- CreateIndex
CREATE INDEX "appointments_shop_id_appointment_date_idx" ON "appointments"("shop_id", "appointment_date");

-- CreateIndex
CREATE INDEX "time_slots_date_idx" ON "time_slots"("date");

-- CreateIndex
CREATE UNIQUE INDEX "time_slots_shop_id_stylist_id_date_start_time_key" ON "time_slots"("shop_id", "stylist_id", "date", "start_time");

-- AddForeignKey
ALTER TABLE "services" ADD CONSTRAINT "services_shop_id_fkey" FOREIGN KEY ("shop_id") REFERENCES "shops"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stylists" ADD CONSTRAINT "stylists_shop_id_fkey" FOREIGN KEY ("shop_id") REFERENCES "shops"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_shop_id_fkey" FOREIGN KEY ("shop_id") REFERENCES "shops"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_stylist_id_fkey" FOREIGN KEY ("stylist_id") REFERENCES "stylists"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "time_slots" ADD CONSTRAINT "time_slots_shop_id_fkey" FOREIGN KEY ("shop_id") REFERENCES "shops"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "time_slots" ADD CONSTRAINT "time_slots_stylist_id_fkey" FOREIGN KEY ("stylist_id") REFERENCES "stylists"("id") ON DELETE SET NULL ON UPDATE CASCADE;
