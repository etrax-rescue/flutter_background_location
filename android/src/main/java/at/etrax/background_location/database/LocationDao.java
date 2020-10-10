package at.etrax.background_location.database;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Update;

import java.util.List;

@Dao
public interface LocationDao {
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    void insert(LocationData locationData);

    @Insert(onConflict =  OnConflictStrategy.IGNORE)
    void bulkInsert(LocationData... locations);

    @Update
    void updateLocations(LocationData... locations);

    @Query("DELETE FROM location_data")
    void deleteAll();

    @Query("SELECT * from location_data ORDER BY time DESC")
    List<LocationData> getAllLocations();

    @Query("SELECT * from location_data ORDER BY time DESC LIMIT 1")
    LocationData getLastLocation();

    @Query("SELECT * from location_data WHERE label IN (:labels)")
    List<LocationData> getLocations(List<String> labels);

    @Query("SELECT * from location_data WHERE label IN (:labels) LIMIT :n")
    List<LocationData> getNLocations(List<String> labels, int n);

    @Query("DELETE FROM location_data WHERE label IN (:labels)")
    void deleteLocations(List<String> labels);

    @Query("SELECT * from location_data WHERE uploaded IS 0 AND label IS :label")
    List<LocationData> getLocationsForUpload(String label);

    @Query("SELECT * from location_data ORDER BY time DESC LIMIT 1")
    LiveData<LocationData> streamLocation();

    @Query("SELECT * from location_data WHERE label IS :label ORDER BY time DESC LIMIT 1")
    LiveData<LocationData> streamLocationWithLabel(String label);
}
