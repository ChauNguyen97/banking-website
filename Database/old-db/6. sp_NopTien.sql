drop PROCEDURE IF EXISTS ThanhToanNo;

DELIMITER //

-- status: 0 : thành công
--		 : 1 : ROLLBACK
--		 : -1 : không tồn tại
create PROCEDURE ThanhToanNo
(idTaiKhoanNo VARCHAR(100), 
idNhacNo VARCHAR(45),
ngayCK DATETIME,
noiDung VARCHAR(45),
partnerCode VARCHAR(45),
signature TEXT,
OUT status INT
)
proc_exit:BEGIN
 	DECLARE tienConLai, soDuMoi DOUBLE;
	
	-- kiểm tra tài khoản nhận có tồn tại
	IF NOT EXISTS (SELECT 1 FROM nhacno where id = idNhacNo);
	THEN
		SET status = -1;
		LEAVE proc_exit;		
	END IF;

	IF EXISTS (SELECT 1 FROM taikhoannganhang 
 							WHERE id = idTaiKhoanChuyen AND soDu >= (SELECT tienNo FROM nhacno where id = idNhacNo))
 	THEN
		START TRANSACTION;
		SET @idTaiKhoanNhan = (SELECT idTaiKhoanTao FROM nhacno where id = idNhacNo);
		SET @soTienNo = (SELECT tienNo FROM nhacno where id = idNhacNo);
		SET @soTKNhan = (SELECT soTK FROM taikhoannganhang where id = @idTaiKhoanNhan);
		SET @soTKChuyen = (SELECT soTK FROM taikhoannganhang WHERE id = idTaiKhoanNo);
 
  		-- trừ tiền của tài khoản A
  			
  		SET @soDuTKChuyen = (SELECT soDu FROM taikhoannganhang WHERE id = idTaiKhoanNo);
  		SET tienConLai = @soDuTKChuyen - giaoDichCK;
		UPDATE taikhoannganhang SET soDu = tienConLai where id = idTaiKhoanNo;

		-- thêm vào bảng lịch sử chuyển khoản
			INSERT INTO lichsuchuyenkhoan(ngay, idTaiKhoanNHGui, soTaiKhoanNhan, 
 													giaoDich, noiDungChuyen, nganHangNhan, idNhacNo)
  		VALUES (ngayCK, idTaiKhoanNo, @soTKNhan, @soTienNo, noiDung, 'HKL Bank', NULL);

		-- thêm tiền vào tài khoản B
			
		SET @soDuTKNhan = (SELECT soDu FROM taikhoannganhang WHERE id = @idTaiKhoanNhan);
		SET soDuMoi = @soDuTKNhan + @soTienNo;
		UPDATE taikhoannganhang SET soDu = soDuMoi WHERE id = @idTaiKhoanNhan;
		UPDATE nhacno SET tinhTrang = 1 WHERE id = @idNhacNo;
			
		COMMIT;
		SET status = 0;
	ELSE
		SET status = -1;
	END IF;

	
	
 	
END $$

