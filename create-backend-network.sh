#!/usr/bin/env bash
#
# Tạo Docker network `backend` với subnet CỐ ĐỊNH.
#
# Mọi service trong repo này khai `backend` là external, tức phải có sẵn trước
# khi `docker compose up`. Đây là nơi duy nhất định nghĩa nó — chạy script này
# thay vì gõ `docker network create backend` bằng tay.
#
# VÌ SAO PHẢI GHIM SUBNET
# Không truyền --subnet thì Docker tự cấp từ pool mặc định 192.168.0.0/16, chia
# theo size /20, theo THỨ TỰ CÁC NETWORK ĐƯỢC TẠO. Máy này còn
# openvnp-server_default và product_ms_default cùng ăn từ pool đó, nên nếu
# `backend` bị xoá rồi tạo lại sau chúng, nó sẽ nhận một dải khác.
#
# Hậu quả không hiển nhiên: ufw có rule `allow from 192.168.0.0/20` để container
# gọi được các cổng dịch vụ publish trên host (Mongo, Postgres...). Dải đổi thì
# rule trỏ nhầm, container mất kết nối, và triệu chứng hiện ra rất xa nguyên
# nhân — dạng "Server selection timed out" của mongoose chứ không phải lỗi
# mạng.
#
# ĐỔI SUBNET thì phải dừng TOÀN BỘ container đang gắn network, `docker network
# rm backend`, sửa hằng số dưới đây, chạy lại script, rồi `docker rm` từng
# container cũ và `docker compose up -d` lại từng service — container ghim
# NETWORK ID chứ không ghim tên, nên `docker start` sẽ báo "network <id> not
# found" và compose cũng chỉ start lại container cũ nếu chưa xoá.

set -euo pipefail

NETWORK=backend
SUBNET=192.168.0.0/20
GATEWAY=192.168.0.1

current=$(docker network inspect "$NETWORK" \
  --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null || true)

if [ -z "$current" ]; then
  docker network create \
    --driver bridge \
    --subnet "$SUBNET" \
    --gateway "$GATEWAY" \
    "$NETWORK" >/dev/null
  echo "đã tạo network '$NETWORK' với subnet $SUBNET"
  exit 0
fi

if [ "$current" = "$SUBNET" ]; then
  echo "network '$NETWORK' đã đúng subnet $SUBNET — không cần làm gì"
  exit 0
fi

echo "CẢNH BÁO: network '$NETWORK' đang dùng subnet $current, không phải $SUBNET" >&2
echo "Script KHÔNG tự sửa vì xoá network sẽ đánh sập mọi container đang gắn vào." >&2
echo "Xem hướng dẫn đổi subnet ở đầu file này." >&2
exit 1
