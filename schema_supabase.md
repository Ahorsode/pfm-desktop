## Table `_prisma_migrations`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `varchar` | Primary |
| `checksum` | `varchar` |  |
| `finished_at` | `timestamptz` |  Nullable |
| `migration_name` | `varchar` |  |
| `logs` | `text` |  Nullable |
| `rolled_back_at` | `timestamptz` |  Nullable |
| `started_at` | `timestamptz` |  |
| `applied_steps_count` | `int4` |  |

## Table `accounts`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `text` | Primary |
| `user_id` | `text` |  |
| `type` | `text` |  |
| `provider` | `text` |  |
| `provider_account_id` | `text` |  |
| `refresh_token` | `text` |  Nullable |
| `access_token` | `text` |  Nullable |
| `expires_at` | `int4` |  Nullable |
| `token_type` | `text` |  Nullable |
| `scope` | `text` |  Nullable |
| `id_token` | `text` |  Nullable |
| `session_state` | `text` |  Nullable |

## Table `audit_logs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `table_name` | `text` |  |
| `record_id` | `int4` |  |
| `attribute_name` | `text` |  |
| `old_value` | `text` |  Nullable |
| `new_value` | `text` |  Nullable |
| `reason` | `text` |  Nullable |
| `user_id` | `text` |  |
| `farm_id` | `int4` |  |
| `created_at` | `timestamp` |  |

## Table `batches`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `status` | `text` |  |
| `arrivalDate` | `timestamp` |  |
| `breedType` | `text` |  |
| `createdAt` | `timestamp` |  |
| `currentCount` | `int4` |  |
| `houseId` | `int4` |  |
| `initialCount` | `int4` |  |
| `updatedAt` | `timestamp` |  |
| `userId` | `text` |  |
| `farmId` | `int4` |  |
| `batchName` | `text` |  |
| `carriage_inward` | `numeric` |  Nullable |
| `growthTargetOverride` | `text` |  Nullable |
| `growth_target` | `text` |  Nullable |
| `initialCostActual` | `numeric` |  Nullable |
| `initialCostCarriage` | `numeric` |  Nullable |
| `initialCostOther` | `jsonb` |  Nullable |
| `initial_actual_cost` | `numeric` |  Nullable |
| `initial_other_costs` | `jsonb` |  Nullable |
| `isolationCount` | `int4` |  |
| `type` | `LivestockType` |  |

## Table `customers`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `name` | `text` |  |
| `phone` | `text` |  Nullable |
| `email` | `text` |  Nullable |
| `address` | `text` |  Nullable |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |
| `balanceOwed` | `numeric` |  |

## Table `daily_feeding_logs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `batch_id` | `int4` |  Nullable |
| `feed_type_id` | `int4` |  Nullable |
| `amount_consumed` | `numeric` |  |
| `log_date` | `timestamp` |  |
| `user_id` | `text` |  Nullable |
| `farmId` | `int4` |  |
| `formulation_id` | `int4` |  Nullable |

## Table `device_registrations`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `farmId` | `int4` |  |
| `userId` | `text` |  |
| `deviceIdentifier` | `text` |  |
| `deviceName` | `text` |  Nullable |
| `registeredAt` | `timestamptz` |  Nullable |

## Table `egg_categories`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `name` | `text` |  |
| `description` | `text` |  Nullable |
| `createdAt` | `timestamp` |  |

## Table `egg_production`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `batchId` | `int4` |  |
| `eggsCollected` | `int4` |  |
| `logDate` | `timestamp` |  |
| `userId` | `text` |  |
| `createdAt` | `timestamp` |  |
| `farmId` | `int4` |  |
| `categoryId` | `int4` |  Nullable |
| `cratesCollected` | `numeric` |  Nullable |
| `eggsRemaining` | `int4` |  |
| `qualityGrade` | `text` |  Nullable |
| `unusableCount` | `int4` |  |

## Table `expenses`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `user_id` | `text` |  |
| `amount` | `numeric` |  |
| `category` | `ExpenseCategory` |  |
| `description` | `text` |  Nullable |
| `expense_date` | `timestamp` |  |
| `created_at` | `timestamp` |  |
| `updated_at` | `timestamp` |  |
| `batch_id` | `int4` |  Nullable |
| `supplierId` | `int4` |  Nullable |

## Table `farm_members`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `userId` | `text` |  |
| `role` | `Role` |  |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |

## Table `farm_settings`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `eggRecordReminderTime` | `text` |  Nullable |
| `feedRecordReminderTime` | `text` |  Nullable |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |
| `currency` | `text` |  |
| `growth_target_standard` | `int4` |  Nullable |
| `eggsPerCrate` | `int4` |  |

## Table `farms`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `name` | `text` |  |
| `location` | `text` |  Nullable |
| `capacity` | `int4` |  |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |
| `userId` | `text` |  |
| `subscriptionTier` | `SubscriptionTier` |  |

## Table `feed_formulation_ingredients`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `formulationId` | `int4` |  |
| `inventoryId` | `int4` |  |
| `quantity` | `numeric` |  Nullable |
| `unit` | `text` |  Nullable |
| `percentage` | `numeric` |  Nullable |

## Table `feed_formulations`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `name` | `text` |  |
| `notes` | `text` |  Nullable |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |
| `targetLivestock` | `LivestockType` |  Nullable |
| `type` | `FeedType` |  |

## Table `growth_standards`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `livestockType` | `LivestockType` |  |
| `ageInDays` | `int4` |  |
| `targetWeight` | `numeric` |  |
| `targetFeed` | `numeric` |  Nullable |
| `unit` | `text` |  |
| `createdAt` | `timestamp` |  |

## Table `health_records`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `batch_id` | `int4` |  Nullable |
| `record_type` | `varchar` |  Nullable |
| `description` | `text` |  Nullable |
| `record_date` | `date` |  |
| `farmId` | `int4` |  |

## Table `houses`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `name` | `text` |  |
| `capacity` | `int4` |  |
| `currentTemperature` | `numeric` |  Nullable |
| `currentHumidity` | `numeric` |  Nullable |
| `userId` | `text` |  |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |
| `isIsolation` | `bool` |  |

## Table `inventory`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `itemName` | `text` |  |
| `stockLevel` | `numeric` |  |
| `unit` | `text` |  |
| `category` | `text` |  Nullable |
| `userId` | `text` |  |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |
| `farmId` | `int4` |  |
| `reorderLevel` | `numeric` |  Nullable |
| `costPerUnit` | `numeric` |  Nullable |
| `eggCategoryId` | `int4` |  Nullable |
| `supplierId` | `int4` |  Nullable |

## Table `invitations`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `email` | `text` |  Nullable |
| `role` | `Role` |  |
| `status` | `text` |  |
| `created_at` | `timestamp` |  |
| `farm_id` | `int4` |  |
| `phone_number` | `text` |  Nullable |
| `updated_at` | `timestamp` |  |

## Table `medication_schedules`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `batchId` | `int4` |  |
| `medicationName` | `text` |  |
| `scheduledDate` | `timestamp` |  |
| `status` | `text` |  |
| `notes` | `text` |  Nullable |
| `farmId` | `int4` |  |

## Table `mortality`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `batchId` | `int4` |  |
| `count` | `int4` |  |
| `reason` | `text` |  Nullable |
| `logDate` | `timestamp` |  |
| `userId` | `text` |  |
| `createdAt` | `timestamp` |  |
| `category` | `text` |  Nullable |
| `farmId` | `int4` |  |
| `sub_category` | `text` |  Nullable |

## Table `order_items`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `orderId` | `int4` |  |
| `description` | `text` |  |
| `quantity` | `int4` |  |
| `unitPrice` | `numeric` |  |
| `totalPrice` | `numeric` |  |
| `inventoryId` | `int4` |  Nullable |
| `livestockId` | `int4` |  Nullable |

## Table `orders`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `customerId` | `int4` |  Nullable |
| `totalAmount` | `numeric` |  |
| `currency` | `text` |  |
| `status` | `text` |  |
| `orderDate` | `timestamp` |  |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |
| `discountAmount` | `numeric` |  |

## Table `sale_items`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `saleId` | `int4` |  |
| `description` | `text` |  |
| `quantity` | `int4` |  |
| `unitPrice` | `numeric` |  |
| `totalPrice` | `numeric` |  |
| `farmId` | `int4` |  |

## Table `sales`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `customerName` | `text` |  Nullable |
| `totalAmount` | `numeric` |  |
| `saleDate` | `timestamp` |  |
| `status` | `text` |  |
| `userId` | `text` |  |
| `createdAt` | `timestamp` |  |
| `farmId` | `int4` |  |

## Table `sessions`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `text` | Primary |
| `session_token` | `text` |  |
| `user_id` | `text` |  |
| `expires` | `timestamp` |  |

## Table `subscription_plans`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `name` | `text` |  |
| `tier` | `SubscriptionTier` |  |
| `price` | `numeric` |  |
| `currency` | `text` |  |
| `interval` | `text` |  |
| `features` | `jsonb` |  Nullable |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |

## Table `subscriptions`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `planId` | `int4` |  |
| `status` | `text` |  |
| `startDate` | `timestamp` |  |
| `endDate` | `timestamp` |  Nullable |

## Table `suppliers`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `farmId` | `int4` |  |
| `name` | `text` |  |
| `phone` | `text` |  Nullable |
| `email` | `text` |  Nullable |
| `address` | `text` |  Nullable |
| `balanceOwed` | `numeric` |  |
| `createdAt` | `timestamp` |  |
| `updatedAt` | `timestamp` |  |

## Table `user_permissions`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `user_id` | `text` |  |
| `farm_id` | `int4` |  |
| `can_view_finance` | `bool` |  |
| `can_edit_finance` | `bool` |  |
| `can_view_inventory` | `bool` |  |
| `can_edit_inventory` | `bool` |  |
| `can_view_batches` | `bool` |  |
| `can_edit_batches` | `bool` |  |
| `can_view_sales` | `bool` |  |
| `can_edit_sales` | `bool` |  |
| `can_view_eggs` | `bool` |  |
| `can_edit_eggs` | `bool` |  |
| `can_view_feeding` | `bool` |  |
| `can_edit_feeding` | `bool` |  |
| `can_view_houses` | `bool` |  |
| `can_edit_houses` | `bool` |  |
| `can_view_mortality` | `bool` |  |
| `can_edit_mortality` | `bool` |  |
| `can_view_customers` | `bool` |  |
| `can_edit_customers` | `bool` |  |
| `can_view_team` | `bool` |  |
| `can_edit_team` | `bool` |  |

## Table `users`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `text` | Primary |
| `firstname` | `text` |  Nullable |
| `surname` | `text` |  Nullable |
| `email` | `text` |  Nullable |
| `email_verified` | `timestamp` |  Nullable |
| `image` | `text` |  Nullable |
| `role` | `Role` |  |
| `created_at` | `timestamp` |  |
| `updated_at` | `timestamp` |  |
| `name` | `text` |  Nullable |
| `phone_number` | `text` |  Nullable |
| `middle_name` | `text` |  Nullable |
| `password` | `text` |  Nullable |
| `must_change_password` | `bool` |  |

## Table `vaccination_schedules`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `batchId` | `int4` |  |
| `vaccineName` | `text` |  |
| `scheduledDate` | `timestamp` |  |
| `status` | `text` |  |
| `notes` | `text` |  Nullable |
| `farmId` | `int4` |  |

## Table `verification_tokens`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `identifier` | `text` |  |
| `token` | `text` |  |
| `expires` | `timestamp` |  |

## Table `weight_records`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `batchId` | `int4` |  |
| `averageWeight` | `numeric` |  |
| `logDate` | `timestamp` |  |
| `userId` | `text` |  |
| `farmId` | `int4` |  |
| `createdAt` | `timestamp` |  |

